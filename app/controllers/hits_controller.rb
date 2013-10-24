class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
    @aggregated_hits = @site.hits.aggregated
  end

  def index
    @hits   = @aggregated_hits.by_path_and_status.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits "All hits", @aggregated_hits.by_date
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
    @points = graph_points_from_hits "Errors", @aggregated_hits.by_date_and_status.errors
  end

  def archives
    @hits   = @aggregated_hits.by_path_and_status.archives.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits "Archives", @aggregated_hits.by_date_and_status.archives
  end

  def redirects
    @hits   = @aggregated_hits.by_path_and_status.redirects.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits "Redirects", @aggregated_hits.by_date_and_status.redirects
  end

  def other
    @hits   = @aggregated_hits.by_path_and_status.other.page(params[:page]).order('count DESC')
    @points = graph_points_from_hits "Other", @aggregated_hits.by_date_and_status.other
  end

  protected

  # Creating format required by
  # https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
  def graph_points_from_hits title, hits
    points = [["Date", title]]
    hits.each do |hit|
      points.push [hit.hit_on.to_s('yyyy-mm-dd'), hit.count]
    end

    return points
  end

end
