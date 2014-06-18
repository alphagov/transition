class ImportBatchesController < ApplicationController
  include Transition::Controller::CheckUserCanEditMappings

  before_filter :find_site
  before_filter :check_user_can_edit

  def new
    @import = ImportBatch.new
  end

  def create
    @batch = ImportBatch.new(params[:import_batch])
    @batch.site = @site
    @batch.user = current_user
    @batch.save!
    redirect_to preview_site_import_batch_path(@site, @batch)
  end

protected
  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end
end
