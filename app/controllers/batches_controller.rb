class BatchesController < ApplicationController
  before_filter :set_batch

  def show
    body = {
      done:  @batch.entries.processed.count,
      total: @batch.entries_to_process.count,
      past_participle: "#{@batch.verb}ed",
    }
    render json: body
  end

private

  def batch_params
    params.permit(:id)
  end

  def set_batch
    @batch = current_user.mappings_batches.find(batch_params[:id])
  end
end
