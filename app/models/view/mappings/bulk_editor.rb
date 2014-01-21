module View
  module Mappings
    ##
    # Load and process params specific to bulk editing, to avoid stuffing
    # controllers full of fields.
    class BulkEditor < BulkBase
      def return_path
        @return_path =
          # Make sure that we're not redirecting to another site from user input
          if params[:return_path] && params[:return_path].start_with?(site_mappings_path + '?')
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
    end
  end
end
