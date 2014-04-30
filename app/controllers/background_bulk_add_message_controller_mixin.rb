module BackgroundBulkAddMessageControllerMixin
  def set_background_bulk_add_status_message
    @reportable_batch = current_user.mappings_batches.reportable.order(:updated_at).last

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
