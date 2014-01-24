module View
  module Mappings
    ##
    # Load and process params specific to bulk adding, to avoid stuffing
    # controllers full of fields.
    class BulkAdder < BulkBase
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
        paths.select(&:present?).map(&:strip)
      end

      def raw_hosts
        hosts = raw_paths.select {|p| p.start_with?('http')}.map do |path|
          #TODO Handle error if parse fails
          uri = URI.parse(path)
          uri.host
        end
        hosts.uniq
      end

      def canonical_paths
        @canonical_paths ||= raw_paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
      end

      def site_has_hosts?
        hosts = raw_hosts
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
        @outcomes = canonical_paths.map do |path|
          m = Mapping.where(site_id: site.id, path: path).first_or_initialize
          if m.new_record?
            m.update_attributes(common_data) ? :created : :creation_failed
          elsif update_existing?
            m.update_attributes(common_data) ? :updated : :update_failed
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

      def success_message
        "#{created_count} mapping".pluralize(created_count) +
        " created and #{updated_count} mapping".pluralize(updated_count) +
        ' updated.'
      end
    end
  end
end
