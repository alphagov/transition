class HitsController < ApplicationController
  def index
    @site = Site.find_by_abbr!(params[:site_id])
    @hits = @site.aggregated_hits.page(params[:page]).order('count DESC')
  end
  
  def summary
    @site = Site.find_by_abbr!(params[:site_id])
    @errors    = @site.aggregated_errors.order('count DESC').take(10)
    @archives  = @site.aggregated_archives.order('count DESC').take(10)
    @redirects = @site.aggregated_redirects.order('count DESC').take(10)
  end
end
