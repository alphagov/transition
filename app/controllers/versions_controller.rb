class VersionsController < ApplicationController
  include BackgroundBulkAddMessageControllerMixin

  before_filter :find_site
  before_filter :set_background_bulk_add_status_message

  def index
    @mapping = Mapping.find(params[:mapping_id])
    @versions = @mapping.versions
  end

private

  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end
end
