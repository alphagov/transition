module Transition

  module Controller
    module MappingsProgress
      def tracks_mappings_progress(options = {})
        class_eval do
          include MappingsProgress

          unless _process_action_callbacks.any? { |c| c.kind == :before && c.filter == :find_site }
            # Make sure find_site is there in the call chain, we depend on it,
            # but don't overwrite if it's different
            before_filter :_find_site, options
          end
          before_filter :set_saved_mappings, options
          before_filter :set_background_bulk_add_status_message, options
        end
      end

    protected
      def _find_site
        @site = Site.find_by_abbr!(params[:site_id])
      end

      def set_saved_mappings
        if flash[:saved_mapping_ids]
          @saved_mappings = Mapping.find(flash[:saved_mapping_ids])
        end
      end

      def set_background_bulk_add_status_message
        @reportable_batch = current_user.mappings_batches
                                        .where(site_id: @site.id)
                                        .reportable
                                        .order(:updated_at)
                                        .last

        # Assumes that the user only cares about the most recent in-progress batch
        if @reportable_batch
          if @reportable_batch.finished?
            @reportable_batch.update_column(:seen_outcome, true)
          end

          flash.now[:batch_progress] = { message: background_status_message, type: message_type }
        end
      end

      def background_status_message
        done = @reportable_batch.entries.processed.count
        total = @reportable_batch.entries_to_process.count
        "#{done} of #{total} #{'mapping'.pluralize(total)} added".html_safe
      end

      def message_type
        if @reportable_batch.succeeded?
          :success
        elsif @reportable_batch.failed?
          :alert
        else
          :info
        end
      end
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.extend Transition::Controller::MappingsProgress
end
