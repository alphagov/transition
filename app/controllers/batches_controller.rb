class BatchesController < ApplicationController
  before_filter :set_batch

  def show
    body = {
      done:  @batch.entries.processed.count,
      total: @batch.entries_to_process.count,
    }
    render json: body
  end

private
  def set_batch
    @batch = current_user.mappings_batches.find(params[:id])
  end
end
