require 'transition/hits/category'

class HitsController < ApplicationController

  before_filter do
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def index
    @category = Transition::Hits::Category['all'].tap do |c|
      c.hits   = grouped.by_path_and_status.page(params[:page]).order('count DESC')
      c.points = graph_points(grouped.by_date, 'All hits')
    end
  end

  def summary
    @sections = Transition::Hits::Category.all.reject { |c| c.name == 'all' }.map do |category|
      category.tap { |c| c.hits = grouped.by_path_and_status.send(category.to_sym).top_ten.to_a }
    end

    @points = Transition::Hits::Category.all.reject { |c| c.name == 'other' }.map do |category|
      category.tap do |c|
        c.points = (c.name == 'all') ? grouped.by_date : grouped.by_date_and_status.send(category.to_sym)
      end
    end
  end

  def category
    # Category - one of %w(archives redirect errors other) (see routes.rb)
    @category = Transition::Hits::Category[params[:category]]

    @category.hits   = grouped.by_path_and_status.send(@category.to_sym).page(params[:page]).order('count DESC')
    @category.points = graph_points(grouped.by_date_and_status.send(@category.to_sym), @category.title)
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
