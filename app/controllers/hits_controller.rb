class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
    @aggregated_hits = @site.hits.aggregated
  end

  def index
    @hits   = @aggregated_hits.by_path_and_status.page(params[:page]).order('count DESC')
    @points = @aggregated_hits.by_date
  end

  def summary
    @sections = {
      'errors'    => @aggregated_hits.by_path_and_status.errors.top_ten.to_a,    # to_a avoids the view incurring
      'archives'  => @aggregated_hits.by_path_and_status.archives.top_ten.to_a,  # several count queries on #any?
      'redirects' => @aggregated_hits.by_path_and_status.redirects.top_ten.to_a,
      'other'     => @aggregated_hits.by_path_and_status.other.top_ten.to_a
    }

    @points = {
      'All'       => @aggregated_hits.by_date,
      'Errors'    => @aggregated_hits.by_date_and_status.errors,
      'Archives'  => @aggregated_hits.by_date_and_status.archives,
      'Redirects' => @aggregated_hits.by_date_and_status.redirects,
    }
  end

  def errors
    @hits   = @aggregated_hits.by_path_and_status.errors.page(params[:page]).order('count DESC')
    @points = @aggregated_hits.by_date_and_status.errors
  end

  def archives
    @hits   = @aggregated_hits.by_path_and_status.archives.page(params[:page]).order('count DESC')
    @points = @aggregated_hits.by_date_and_status.archives
  end

  def redirects
    @hits   = @aggregated_hits.by_path_and_status.redirects.page(params[:page]).order('count DESC')
    @points = @aggregated_hits.by_date_and_status.redirects
  end

  def other
    @hits   = @aggregated_hits.by_path_and_status.other.page(params[:page]).order('count DESC')
    @points = @aggregated_hits.by_date_and_status.other
  end

end
