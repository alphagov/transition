module View
  module Mappings
    ##
    # Load and process params specific to bulk adding, to avoid stuffing
    # controllers full of fields.
    class BulkAdder < BulkBase
      def http_status
        params[:http_status] if Mapping::TYPES.keys.include?(params[:http_status])
      end

      def operation_description
        type = Mapping::TYPES[http_status]
        update_type = update_existing? ? 'overwrite' : 'ignore'
        "bulk-add-#{type}-#{update_type}-existing"
      end

      # Take either a multiline string of paths, one per line (as submitted by
      # the new_multiple form) or an array of path strings (as submitted by the
      # hidden fields on the confirmation page) and return the paths in an
      # array, ignoring any lines which are blank and stripping whitespace from
      # around the rest.
      def raw_paths
        return [] unless (paths = params[:paths])

        # Efficiently match any combination of new line characters:
        #     http://stackoverflow.com/questions/10805125
        paths = paths.split(/\r?\n|\r/) if paths.is_a?(String)
        # Ignore all URLs or paths with < or > in them.
        paths = paths.select(&:present?).reject { |p| p =~ /(<|>)/ }
        paths.map(&:strip)
      end

      def raw_hosts
        hosts = raw_paths.select {|p| p.start_with?('http')}.map do |path|
          uri = URI.parse(path)
          uri.host
        end
        hosts.uniq
      end

      def tag_list
        @tag_list ||= begin
          test_mapping.tag_list = params[:tag_list]
          test_mapping.tag_list
        end
      end

      def canonical_paths
        @canonical_paths ||= raw_paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
      end

      def site_has_hosts?
        begin
          hosts = raw_hosts
        rescue URI::InvalidURIError
          return false
        end
        hosts.empty? || hosts.size == site.hosts.where(hostname: hosts).size
      end

      def existing_mappings
        @existing_mappings ||= Mapping.where(site_id: site.id, path: canonical_paths)
      end

      def all_mappings
        canonical_paths.map do |path|
          existing_mappings.find { |m| m.path == path } ||
            Mapping.new(site: site, path: path)
        end
      end

      def params_errors
        {}.tap do |errors|
          errors[:http_status] = I18n.t('mappings.bulk.http_status_invalid') if http_status.blank?
          errors[:paths]       = I18n.t('mappings.bulk.add.paths_empty')     if canonical_paths.empty?
          errors[:paths]       = I18n.t('mappings.bulk.add.hosts_invalid')   if !site_has_hosts?
          errors[:new_url]     = I18n.t('mappings.bulk.new_url_invalid')     if would_fail_on_new_url?
        end
      end

      def update_existing?
        params[:update_existing] == "true"
      end

      def create_or_update!
        @modified_mappings = []
        @outcomes = canonical_paths.map do |path|
          m = Mapping.where(site_id: site.id, path: path).first_or_initialize
          m.attributes = common_data
          m.tag_list = [m.tag_list, params[:tag_list]].join(',')

          if m.new_record?
            if m.save
              @modified_mappings << m
              :created
            else
              :creation_failed
            end
          elsif update_existing?
            if m.save
              @modified_mappings << m
              :updated
            else
              :update_failed
            end
          else
            :not_updating
          end
        end
      end

      def outcomes
        @outcomes
      end

      def created_count
        outcomes.count(:created)
      end

      def updated_count
        outcomes.count(:updated)
      end

      def modified_mappings
        @modified_mappings
      end

      def tagged_with(opts = {all: false, and: false})
        %(#{opts[:all] ? '. All ' : ''}#{opts[:and] ? ' and ' : ''}tagged with "#{tag_list.join(', ')}") if tag_list.any?
      end

      def mappings_created
        "#{created_count} #{'mapping'.pluralize(created_count)} created"
      end

      def mappings_updated
        "#{updated_count} #{'mapping'.pluralize(updated_count)} updated"
      end

      def success_message
        if updated_count.zero?
          I18n.t('mappings.bulk.add.success.all_created',
                 created: mappings_created,
                 tagged_with: tagged_with(and: true))
        elsif created_count.zero?
          I18n.t('mappings.bulk.add.success.all_updated',
                 updated: mappings_updated,
                 tagged_with: tagged_with(and: true))
        else
          I18n.t('mappings.bulk.add.success.some_updated',
                 created: mappings_created,
                 updated: mappings_updated,
                 tagged_with: tagged_with(all: true))
        end
      end
    end
  end
end
