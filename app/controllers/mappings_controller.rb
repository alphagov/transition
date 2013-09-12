class MappingsController < ApplicationController
  def index
    @site = Site.find_by_abbr(params[:site_id])
  end
end
