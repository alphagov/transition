class ImportBatchesController < ApplicationController
  include Transition::Controller::CheckUserCanEditMappings

  before_filter :find_site
  before_filter :check_user_can_edit

  def new
    @import = ImportBatch.new
  end

  def create

  end

protected
  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end
end
