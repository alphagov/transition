class BatchesController < ApplicationController
  def show
    @batch = current_user.mappings_batches.find(:first, params[:id])
    render json: {}, status: 404 and return if @batch.nil?

    body = {
      done:  @batch.entries.processed.count,
      total: @batch.entries_to_process.count,
      past_participle: "#{@batch.verb}ed",
    }
    render json: body
  end
end
