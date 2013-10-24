class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
    @aggregated_hits = @site.hits.aggregated
  end

  def index
    @hits = @aggregated_hits.page(params[:page]).order('count DESC')
  end

  def summary
    @sections = {
      'errors'    => @aggregated_hits.errors.top_ten.to_a,    # to_a avoids the view incurring
      'archives'  => @aggregated_hits.archives.top_ten.to_a,  # several count queries on #any?
      'redirects' => @aggregated_hits.redirects.top_ten.to_a,
      'other'     => @aggregated_hits.other.top_ten.to_a
    }
  end

  def errors
    @hits = @aggregated_hits.errors.page(params[:page]).order('count DESC')
  end

  def archives
    @hits = @aggregated_hits.archives.page(params[:page]).order('count DESC')
  end

  def redirects
    @hits = @aggregated_hits.redirects.page(params[:page]).order('count DESC')
  end
  
  def other
    @hits = @aggregated_hits.other.page(params[:page]).order('count DESC')
  end

end
