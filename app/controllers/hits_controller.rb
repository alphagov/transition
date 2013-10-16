class HitsController < ApplicationController
  def index
    @site = Site.find_by_abbr!(params[:site_id])
    @hits = @site.aggregated_hits.page(params[:page]).order('count DESC')
  end
end
