class MappingsController < ApplicationController
  def index
    @site = Site.find_by_abbr(params[:site_id])
    @mappings = @site.mappings.page(params[:page])
  end
end
