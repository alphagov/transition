class HitsController < ApplicationController
  before_filter :find_site, :period

  def index
    @category = View::Hits::Category['all'].tap do |c|
      c.hits   = date_range.by_path_and_status.page(params[:page]).order('count DESC')
      c.points = date_range.by_date
    end
  end

  def summary
    @sections = View::Hits::Category.all.reject { |c| c.name == 'all' }.map do |category|
      category.tap do |c|
        c.hits = date_range.by_path_and_status.send(category.to_sym).top_ten.to_a
      end
    end

    @point_categories = View::Hits::Category.all.reject { |c| c.name == 'other' }.map do |category|
      category.tap do |c|
        c.points = ((c.name == 'all') ? date_range.by_date : date_range.by_date_and_status.send(category.to_sym))
      end
    end
  end

  def category
    # Category - one of %w(archives redirect errors other) (see routes.rb)
    @category = View::Hits::Category[params[:category]].tap do |c|
      c.hits   = date_range.by_path_and_status.send(c.to_sym).page(params[:page]).order('count DESC')
      c.points = params[:category] == 'other' ? date_range.by_date.other : date_range.by_date_and_status.send(c.to_sym)
    end
  end

  protected

  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def grouped
    @site.hits.grouped
  end

  def period
    @period ||= (View::Hits::TimePeriod[params[:period]] || View::Hits::TimePeriod.default)
  end

  def date_range
    grouped.in_range(period.start_date, period.end_date)
  end
end
