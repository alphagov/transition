module View
  module Mappings
    ##
    # Load all the fields associated with a bulk adding operation
    # to avoid stuffing controllers full of fields.
    #
    # Needs a site and params to work out what should be created
    class BulkAdder < Struct.new(:site, :params, :back_to_index)
      ERRORS = {
        http_status_invalid: 'Please select either redirect or archive',
        paths_empty: 'Enter at least one valid path',
        new_url_invalid: 'Enter a valid URL to redirect to'
      }

      # Take either a multiline string of paths, one per line (as submitted by
      # the new_multiple form) or an array of path strings (as submitted by the
      # hidden fields on the confirmation page) and return the paths in an
      # array, ignoring any lines which are blank and stripping whitespace from
      # around the rest.
      def raw_paths
        paths = params[:paths]
        if paths
          if paths.is_a?(String)
            # Efficiently match any combination of new line characters:
            #     http://stackoverflow.com/questions/10805125
            paths = paths.split(/\r?\n|\r/)
          end
          paths.select { |p| p.present? }.map { |p| p.strip }
        else
          []
        end
      end

      def canonical_paths
        raw_paths.map { |p| site.canonical_path(p) }.select { |p| p.present? }.uniq
      end

      def existing_mappings
        @existing_mappings ||= Mapping.where(site_id: site.id, path: canonical_paths)
      end

      def all_mappings
        canonical_paths.map do |path|
          i = existing_mappings.find_index { |m| m.path == path }
          if i
            existing_mappings[i]
          else
            Mapping.new(site: site, path: path)
          end
        end
      end

      def http_status
        params[:http_status] if ['301', '410'].include?(params[:http_status])
      end

      def params_invalid?
        params_errors.present?
      end

      def params_errors
        errors = {}
        errors[:http_status] = ERRORS[:http_status_invalid] if http_status.blank?
        errors[:paths]       = ERRORS[:paths_empty]         if canonical_paths.empty?
        errors[:new_url]     = ERRORS[:new_url_invalid]     if would_fail_on_new_url?
        errors
      end

      def common_data
        @common_data = { http_status: http_status }.tap do |common_data|
          common_data[:new_url] = new_url if http_status == '301'
        end
      end

      def new_url
        params[:new_url]
      end

      def would_fail?
        !test_mapping.valid?
      end

      def would_fail_on_new_url?
        would_fail? &&
          test_mapping.errors.size == 1 && test_mapping.errors[:new_url].present?
      end

      def test_mapping
        # Before trying to create any real mappings, construct a test mapping using
        # the submitted data to see if it validates:
        @test_mapping ||= Mapping.new({
                                        site: site,
                                        path: '/this/is/a/test/and/will/not/be/saved'
                                      }.merge(common_data))

      end

      def create!
        @outcomes = canonical_paths.map do |path|
          begin
            Mapping.create!({
                              site: site,
                              path: path,
                            }.merge(common_data))
          rescue ActiveRecord::RecordInvalid
            false
          end
        end
      end

      def success_count
        @outcomes.size - failure_count
      end

      def failure_count
        @outcomes.count(false)
      end
    end
  end
end
