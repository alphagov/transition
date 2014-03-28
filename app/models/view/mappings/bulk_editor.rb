require 'transition/off_site_redirect_checker'

module View
  module Mappings
    ##
    # Load and process params specific to bulk editing, to avoid stuffing
    # controllers full of fields.
    class BulkEditor < BulkBase
      def http_status
        operation if Mapping::TYPES.keys.include?(operation)
      end

      def operation
        params[:operation]
      end

      def operation_description
        "bulk-edit-#{Mapping::TYPES[operation]}"
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
        case
        when mappings.empty?    then I18n.t('mappings.bulk.edit.mappings_empty')
        when http_status.blank? then I18n.t('mappings.bulk.http_status_invalid')
        end
      end

      def update!
        @failure_ids = mappings.map do |m|
          # update_attributes validates before saving
          m.update_attributes(common_data) ? nil : m.id
        end.compact
      end

      def failures?
        @failure_ids.any?
      end

      def failures
        site.mappings.where(id: @failure_ids).order(:path)
      end

      def success_message
        'Mappings updated successfully'
      end
    end
  end
end
