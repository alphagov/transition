module BackgroundBulkAddMessageControllerMixin
  def set_background_bulk_add_status_message
    # Assumes that the user only cares about the most recent in-progress batch
    if batch = current_user.mappings_batches.reportable.order(:updated_at).last
      if batch.finished?
        batch.update_column(:seen_outcome, true)
      end

      flash.now[:batch_progress] = { message: background_status_message(batch), type: message_type(batch) }
    end
  end

  def background_status_message(batch)
    done = batch.entries.processed.count
    total = batch.entries_to_process.count
    "#{done} of #{total} #{'mapping'.pluralize(total)} added".html_safe
  end

  def message_type(batch)
    if batch.succeeded?
      :success
    elsif batch.failed?
      :alert
    else
      :info
    end
  end
end
