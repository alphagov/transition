class BatchesController < ApplicationController
  before_action :set_batch

  def show
    body = {
      done: @batch.entries.processed.count,
      total: @batch.entries_to_process.count,
      past_participle: "#{@batch.verb}ed",
    }
    render json: body
  end

private

  def set_batch
    @batch = current_user.mappings_batches.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head 404
  end
end
