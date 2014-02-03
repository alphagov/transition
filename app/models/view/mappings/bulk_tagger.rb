module View
  module Mappings
    ##
    # Load and process params specific to bulk tagging, to avoid stuffing
    # controllers full of fields.
    class BulkTagger < BulkEditor
      def params_errors
        I18n.t('mappings.bulk.edit.mappings_empty') if mappings.empty?
      end

      def http_status
        super || ('tag' if params[:http_status] == 'tag')
      end

      def tag_list
        params[:tag_list]
      end

      def update!
        @failure_ids = mappings.map do |m|
          m.tag_list -= common_tags
          m.tag_list += tags_as_array
          m.save ? nil : m.id
        end.compact
      end

      def success_message
        successes = mappings.count - @failure_ids.length
        "#{successes} #{ 'mapping'.pluralize(successes) } tagged \"#{tag_list}\""
      end
    end
  end
end
