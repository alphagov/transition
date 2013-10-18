class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def index
    @hits = @site.aggregated_hits.page(params[:page]).order('count DESC')
  end

  def summary
    @sections = {
      'errors'    => @site.aggregated_errors.order('count DESC').take(10),
      'archives'  => @site.aggregated_archives.order('count DESC').take(10),
      'redirects' => @site.aggregated_redirects.order('count DESC').take(10),
      'other'     => @site.aggregated_other.order('count DESC').take(10)
    }
  end

  def errors
    @hits = @site.aggregated_errors.page(params[:page]).order('count DESC')
  end

  def archives
    @hits = @site.aggregated_archives.page(params[:page]).order('count DESC')
  end

  def redirects
    @hits = @site.aggregated_redirects.page(params[:page]).order('count DESC')
  end
  
  def other
    @hits = @site.aggregated_other.page(params[:page]).order('count DESC')
  end

end
