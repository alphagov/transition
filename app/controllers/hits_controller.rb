class HitsController < ApplicationController
  def index
    @site = Site.find_by_abbr!(params[:site_id])
    @hits = @site.aggregated_hits.page(params[:page]).order('count DESC')
  end
  
  def summary
    @site = Site.find_by_abbr!(params[:site_id])
    @errors    = @site.aggregated_errors.page(params[1]).per(10).order('count DESC')
    @archives  = @site.aggregated_archives.page(params[1]).per(10).order('count DESC')
    @redirects = @site.aggregated_redirects.page(params[1]).per(10).order('count DESC')
  end
end
