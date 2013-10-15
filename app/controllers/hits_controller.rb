class HitsController < ApplicationController
  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def index
    @hits = @site.hits.order('hits.count DESC')
  end
end
