module BackgroundBulkAddMessageControllerMixin
  def set_background_bulk_add_status_message
    # Assumes that the user only cares about the most recent in-progress batch
    if batch = current_user.mappings_batches.unfinished.order(:updated_at).last
      flash.now[:info] = background_status_message(batch)
    end
  end

  def background_status_message(batch)
    done = batch.entries.processed.count
    total = batch.entries_to_process.count
    "#{done} of #{total} #{'mapping'.pluralize(total)} processed".html_safe
  end
end
