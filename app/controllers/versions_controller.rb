class VersionsController < ApplicationController

  before_filter :find_site

  def index
    @mapping = Mapping.find(params[:mapping_id])
    @versions = @mapping.versions
  end

private

  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end
end
