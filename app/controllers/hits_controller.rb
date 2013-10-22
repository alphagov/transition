class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def index
    @hits = @site.aggregated_hits.page(params[:page]).order('count DESC')
  end

  def summary
    @sections = {
      'errors'    => @site.aggregated_errors.top_ten.to_a,    # to_a avoids the view incurring
      'archives'  => @site.aggregated_archives.top_ten.to_a,  # several count queries on #any?
      'redirects' => @site.aggregated_redirects.top_ten.to_a,
      'other'     => @site.aggregated_other.top_ten.to_a
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
