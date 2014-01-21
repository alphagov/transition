module View
  module Mappings
    ##
    # Load and validate params used by both bulk adding and editing.
    class BulkBase < Struct.new(:site, :params, :site_mappings_url)
      def http_status
        params[:http_status] if ['301', '410'].include?(params[:http_status])
      end

      def new_url
        params[:new_url]
      end

      def common_data
        @common_data ||= { http_status: http_status }.tap do |common_data|
          common_data[:new_url] = new_url if http_status == '301'
        end
      end

      def params_invalid?
        params_errors.present?
      end

      def would_fail?
        !test_mapping.valid?
      end

      def would_fail_on_new_url?
        would_fail? &&
          test_mapping.errors.size == 1 && test_mapping.errors[:new_url].present?
      end

      def test_mapping
        # Before trying to update any real mappings, construct a test mapping using
        # the submitted data to see if it validates:
        @test_mapping ||= Mapping.new({
                                        site: site,
                                        path: '/this/is/a/test/and/will/not/be/saved'
                                      }.merge(common_data))

      end
    end
  end
end
