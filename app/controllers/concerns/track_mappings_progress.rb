module TrackMappingsProgress
  def tracks_mappings_progress(options = {})
    class_eval do
      include TrackMappingsProgress

      unless _process_action_callbacks.any? { |c| c.kind == :before && c.filter == :find_site }
        # Make sure find_site is there in the call chain, we depend on it,
        # but don't overwrite if it's different
        before_action :_find_site, options
      end
      before_action :set_saved_mappings, options
      before_action :set_background_batch_status_message, options
      before_action :prevent_caching, options
    end
  end

protected

  def _find_site
    @site = Site.find_by!(abbr: params[:site_id])
  end

  def set_saved_mappings
    if flash[:saved_mapping_ids]
      @saved_mappings = Mapping.find(flash[:saved_mapping_ids])
    end
  end

  def set_background_batch_status_message
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
    past_participle = "#{@reportable_batch.verb}ed"
    "#{done} of #{total} #{'mapping'.pluralize(total)} #{past_participle}".html_safe
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

  def anything_to_display?
    flash[:saved_mapping_ids].present? || @reportable_batch
  end

  def prevent_caching
    # Disable caching on responses which include feedback on progress to
    # avoid confusing users who hit the back button.
    if anything_to_display?
      # http://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.extend TrackMappingsProgress
end
