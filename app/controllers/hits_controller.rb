class HitsController < ApplicationController
  before_filter :find_site, :set_period

  def index
    @category = View::Hits::Category['all'].tap do |c|
      c.hits   = hits_in_period.by_path_and_status.page(params[:page]).order('count DESC')
      c.points = totals_in_period
    end
  end

  def summary
    @sections = View::Hits::Category.all.reject { |c| c.name == 'all' }.map do |category|
      category.tap do |c|
        c.hits = hits_in_period.by_path_and_status.send(category.to_sym).top_ten
      end
    end

    unless @period.single_day?
      @point_categories = View::Hits::Category.all.map do |category|
        category.tap do |c|
          c.points = ((c.name == 'all') ? totals_in_period : totals_in_period.send(category.to_sym))
        end
      end
    end
  end

  def category
    # Category - one of %w(archives redirect errors) (see routes.rb)
    @category = View::Hits::Category[params[:category]].tap do |c|
      c.hits   = hits_in_period.by_path_and_status.send(c.to_sym).page(params[:page]).order('count DESC')
      c.points = totals_in_period.by_date_and_status.send(c.to_sym)
    end
  end

  protected

  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def set_period
    @period = (View::Hits::TimePeriod[params[:period]] || View::Hits::TimePeriod.default)
  end

  def hits_in_period
    @site.hits.in_range(@period.start_date, @period.end_date)
  end

  def totals_in_period
    @site.daily_hit_totals.by_date.in_range(@period.start_date, @period.end_date)
  end
end
