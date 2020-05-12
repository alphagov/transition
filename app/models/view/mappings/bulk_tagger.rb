require "set"

module View
  module Mappings
    ##
    # Load and process params specific to bulk tagging, to avoid stuffing
    # controllers full of fields.
    class BulkTagger < BulkEditor
      def params_errors
        I18n.t("mappings.bulk.edit.mappings_empty") if mappings.empty?
      end

      def would_fail?
        false
      end

      def analytics_event_type
        "bulk-edit-tag"
      end

      def tag_list
        prettified_tag_list || common_tags.join(glue)
      end

      def prettified_tag_list
        params[:tag_list] && params[:tag_list].split(delimiter).map(&:strip).join(glue)
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
        @failure_ids = mappings.map { |m|
          m.tag_list -= common_tags
          m.tag_list += tags_as_array
          m.save ? nil : m.id
        }.compact
      end

      def success_message
        successes = mappings.count - @failure_ids.length
        if tag_list.blank?
          "Tags removed from #{successes} #{'mapping'.pluralize(successes)}"
        else
          "#{successes} #{'mapping'.pluralize(successes)} tagged “#{tag_list}”"
        end
      end

    private

      def delimiter
        ActsAsTaggableOn.delimiter
      end

      def glue
        delimiter + " "
      end
    end
  end
end
