class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def index
    @hits   = grouped.by_path_and_status.page(params[:page]).order('count DESC')
    @points = graph_points(grouped.by_date, 'All hits')
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

  def category
    # Category - one of %w(archives redirect errors other) (see routes.rb)
    @category = params[:category]
    category_hits = grouped.by_path_and_status.send(@category.to_sym)

    @hits   = category_hits.page(params[:page]).order('count DESC')
    @points = graph_points(category_hits, @category.titleize)
  end

  protected

  ##
  # Creates format required by
  # https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
  def graph_points(hits, title)
    hits.inject([['Date', title]]) do |points, hit|
      points << [hit.hit_on.to_s('yyyy-mm-dd'), hit.count]
    end
  end

  def grouped
    @site.hits.grouped
  end
end
