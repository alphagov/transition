class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def index
    @hits   = grouped.by_path_and_status.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits "All hits", grouped.by_date
  end

  def summary
    @sections = {
      'errors'    => grouped.by_path_and_status.errors.top_ten.to_a,    # to_a avoids the view incurring
      'archives'  => grouped.by_path_and_status.archives.top_ten.to_a,  # several count queries on #any?
      'redirects' => grouped.by_path_and_status.redirects.top_ten.to_a,
      'other'     => grouped.by_path_and_status.other.top_ten.to_a
    }

    @points = {
      'All'       => grouped.by_date,
      'Errors'    => grouped.by_date_and_status.errors,
      'Archives'  => grouped.by_date_and_status.archives,
      'Redirects' => grouped.by_date_and_status.redirects,
    }
  end

  def errors
    @hits   = grouped.by_path_and_status.errors.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits 'Errors', grouped.by_date_and_status.errors
  end

  def archives
    @hits   = grouped.by_path_and_status.archives.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits 'Archives', grouped.by_date_and_status.archives
  end

  def redirects
    @hits   = grouped.by_path_and_status.redirects.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits 'Redirects', grouped.by_date_and_status.redirects
  end

  def other
    @hits   = grouped.by_path_and_status.other.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits 'Other', grouped.by_date_and_status.other
  end

  protected

  ##
  # Creates format required by
  # https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
  def graph_points_from_hits(title, hits)
    hits.inject([['Date', title]]) do |points, hit|
      points << [hit.hit_on.to_s('yyyy-mm-dd'), hit.count]
    end
  end

  def grouped
    @site.hits.grouped
  end
end
