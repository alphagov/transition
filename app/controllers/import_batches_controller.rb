class ImportBatchesController < ApplicationController
  include Transition::Controller::CheckUserCanEditMappings

  before_filter :find_site
  before_filter :check_user_can_edit

  def new
    @batch = ImportBatch.new
  end

  def create
    @batch = ImportBatch.new(params[:import_batch])
    @batch.site = @site
    @batch.user = current_user
    @batch.save!
    redirect_to preview_site_import_batch_path(@site, @batch)
  end

  def preview
    @batch = @site.import_batches.find(params[:id])
    @redirect_count   = @batch.entries.without_existing_mappings.redirects.count
    @archive_count    = @batch.entries.without_existing_mappings.archives.count
    @unresolved_count = @batch.entries.without_existing_mappings.unresolved.count
    @overwrite_count  = @batch.entries.with_existing_mappings.count
  end

protected
  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end
end
