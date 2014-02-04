require 'set'

module View
  module Mappings
    ##
    # Load and process params specific to bulk tagging, to avoid stuffing
    # controllers full of fields.
    class BulkTagger < BulkEditor
      def params_errors
        I18n.t('mappings.bulk.edit.mappings_empty') if mappings.empty?
      end

      def common_data
        {}
      end

      def would_fail?
        false
      end

      def tag_list
        params[:tag_list] || common_tags.join(ActsAsTaggableOn.delimiter + ' ')
      end

      ##
      # Returns an array of common tags from the mappings
      def common_tags
        # reduce by intersection of Enumerable
        @common_tags ||= mappings.map(&:tag_list).reduce(&:&)
      end

      def tags_as_array
        @tags_as_array ||= begin
          test_mapping.tag_list = tag_list
          test_mapping.tag_list
        end
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
