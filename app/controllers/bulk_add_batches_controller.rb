require 'view/mappings/canonical_filter'

class BulkAddBatchesController < ApplicationController
  include PaperTrail::Rails::Controller

  tracks_mappings_progress except: [:find_global]

  checks_user_can_edit

  def new
    paths = params[:paths].present? ? params[:paths].split(',') : []
    @batch = BulkAddBatch.new(paths: paths)
  end

  def new_multiple_confirmation
    @batch = BulkAddBatch.new(type:     mappings_batch_params[:type],
                               new_url:  mappings_batch_params[:new_url],
                               tag_list: mappings_batch_params[:tag_list],
                               paths:    mappings_batch_params[:paths].split(/\r?\n|\r/).map(&:strip))
    @batch.user = current_user
    @batch.site = @site

    unless @batch.save
      render action: 'new'
    end
  end

  def create_multiple
    @batch = @site.mappings_batches.find(params[:id])
    if @batch.state == 'unqueued'
      @batch.update_attributes!(
        update_existing: mappings_batch_params[:update_existing],
        tag_list:        mappings_batch_params[:tag_list],
        state:           'queued')
      if @batch.invalid?
        render action: 'new_multiple_confirmation' and return
      end

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

    if Transition::OffSiteRedirectChecker.on_site?(params[:return_path])
      redirect_to params[:return_path]
    else
      redirect_to site_mappings_path(@site)
    end
  end

private
  def mappings_batch_params
    params.permit(:type,
                  :paths,
                  :new_url,
                  :tag_list,
                  :update_existing)
  end
end
