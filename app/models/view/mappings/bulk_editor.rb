require "transition/off_site_redirect_checker"

module View
  module Mappings
    ##
    # Load and process params specific to bulk editing, to avoid stuffing
    # controllers full of fields.
    class BulkEditor
      attr_accessor :site, :params, :site_mappings_path

      def initialize(site, params, site_mappings_path = nil)
        @site = site
        @params = params
        @site_mappings_path = site_mappings_path
      end

      def type
        operation if Mapping::SUPPORTED_TYPES.include?(operation)
      end

      def operation
        params[:operation]
      end

      def analytics_event_type
        "bulk-edit-#{type}"
      end

      def return_path
        @return_path ||=
          if Transition::OffSiteRedirectChecker.on_site?(params[:return_path])
            params[:return_path]
          else
            site_mappings_path
          end
      end

      def mappings
        @mappings ||= site.mappings.where(id: params[:mapping_ids]).order(:path)
      end

      def params_errors
        if mappings.empty? then I18n.t("mappings.bulk.edit.mappings_empty")
        elsif type.blank? then I18n.t("mappings.bulk.type_invalid")
        end
      end

      def update!
        @failure_ids = mappings.map { |m|
          m.update(common_data) ? nil : m.id
        }.compact
      end

      def failures?
        @failure_ids.any?
      end

      def failures
        site.mappings.where(id: @failure_ids).order(:path)
      end

      def success_message
        "Mappings updated successfully"
      end

      def new_url
        params[:new_url]
      end

      def common_data
        @common_data ||= { type: type }.tap do |common_data|
          common_data[:new_url] = new_url if type == "redirect"
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

      def new_url_error
        if test_mapping.errors[:new_url].present?
          test_mapping.errors.full_messages_for(:new_url).first
        end
      end

      def test_mapping
        # Before trying to update any real mappings, construct a test mapping using
        # the submitted data to see if it validates:
        @test_mapping ||= Mapping.new({
          site: site,
          path: "/this/is/a/test/and/will/not/be/saved",
        }.merge(common_data))
      end
    end
  end
end
