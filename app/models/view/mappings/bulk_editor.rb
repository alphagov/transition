module View
  module Mappings
    ##
    # Load and process params specific to bulk editing, to avoid stuffing
    # controllers full of fields.
    class BulkEditor < BulkBase
      def return_url
        @return_url =
          case
          # We've just left a non-default mappings index page, so pass its URL on to the form
          when referer && referer.start_with?(site_mappings_url + '?')
            referer
          # We've received return_url and should either redirect to it or pass it back to a form
          when params[:return_url] && params[:return_url].start_with?(site_mappings_url + '?')
            params[:return_url]
          # Use the default mappings index, either because the referer or params
          # value weren't valid to use, weren't received or were this anyway
          else
            site_mappings_url
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
