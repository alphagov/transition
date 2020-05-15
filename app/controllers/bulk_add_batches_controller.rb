require "view/mappings/canonical_filter"
require "transition/off_site_redirect_checker"

class BulkAddBatchesController < ApplicationController
  include PaperTrail::Rails::Controller
  include CheckSiteIsNotGlobal

  before_action :find_site
  check_site_is_not_global
  checks_user_can_edit
  before_action :find_batch, only: %i[preview import]

  def new
    paths = params[:paths].present? ? params[:paths].split(",") : []
    @batch = BulkAddBatch.new(paths: paths)
  end

  def create
    @batch = BulkAddBatch.new(
      type: batch_params[:type],
      new_url: batch_params[:new_url],
      tag_list: batch_params[:tag_list],
      paths: batch_params[:paths].split(/\r?\n|\r/).map(&:strip),
    )
    @batch.user = current_user
    @batch.site = @site

    if @batch.save
      redirect_to preview_site_bulk_add_batch_path(@site, @batch, return_path: params[:return_path])
    else
      render action: "new"
    end
  end

  def preview
    @bulk_add_cancel_destination = preview_destination
  end

  def import
    if @batch.state == "unqueued"
      @batch.update!(batch_params.merge(state: "queued"))

      if @batch.entries_to_process.count > 20
        MappingsBatchWorker.perform_async(@batch.id)
        flash[:show_background_batch_progress_modal] = true
      else
        @batch.process
        @batch.update_column(:seen_outcome, true)

        outcome = BatchOutcomePresenter.new(@batch)
        flash[:saved_mapping_ids] = outcome.affected_mapping_ids
        flash[:success] = outcome.success_message
        flash[:saved_operation] = outcome.analytics_event_type
      end
    end

    redirect_to preview_destination
  end

private

  def preview_destination
    if Transition::OffSiteRedirectChecker.on_site?(params[:return_path])
      params[:return_path]
    else
      site_mappings_path(site_id: @site)
    end
  end

  def batch_params
    params.permit(
      :type,
      :paths,
      :new_url,
      :tag_list,
      :update_existing,
    )
  end

  def find_site
    @site = Site.find_by!(abbr: params[:site_id])
  end

  def find_batch
    @batch = @site.bulk_add_batches.find(params[:id])
  end
end
