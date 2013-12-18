module View
  module Mappings
    ##
    # Load all the fields associated with a bulk editing operation
    # to avoid stuffing controllers full of fields.
    #
    # Needs a site and params to work out what is being edited
    # and what the new values are
    class BulkEditor < Struct.new(:site, :params)
      def mappings
        @mappings ||= site.mappings.where(id: params[:mapping_ids]).order(:path)
      end

      def http_status
        params[:http_status] if ['301', '410'].include?(params[:http_status])
      end

      def params_invalid?
        params_invalid_notice.present?
      end

      def params_invalid_notice
        case
        when mappings.empty?    then 'No mappings were selected'
        when http_status.blank? then 'Please select either redirect or archive'
        end
      end

      def updates
        @updates = { http_status: http_status }.tap do |updates|
          updates[:new_url] = new_url if http_status == '301'
        end
      end

      def new_url
        params[:new_url]
      end

      def update!
        @failures = mappings.map do |m|
          # update_attributes validates before saving
          m.update_attributes(updates) ? nil : m.id
        end.compact
      end

      def failures?
        @failures.any?
      end

      def failed_updates
        site.mappings.where(id: @failures).order(:path)
      end

      def would_fail?
        !test_mapping.valid?
      end

      def would_fail_on_url?
        test_mapping.errors.size == 1 && test_mapping.errors[:new_url].present?
      end

      def test_mapping
        # Before trying to update any real mappings, construct a test mapping using
        # the submitted data to see if it validates:
        @test_mapping ||= begin
          test_data = {
            site: site,
            path: '/this/is/a/test/and/will/not/be/saved'
          }.merge(updates)
          Mapping.new(test_data)
        end
      end
    end
  end
end
