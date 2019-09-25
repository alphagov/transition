class HitsController < ApplicationController
  before_action :set_period

  tracks_mappings_progress except: %i[universal_summary universal_category]

  def index
    @category = View::Hits::Category["all"].tap do |c|
      c.points = totals_in_period

      c.hits = if @period.slug == "all-time" && @site.able_to_use_view?
                 @site.precomputed_all_hits
                   .includes(:mapping, host: :site).page(params[:page])
               else
                 hits_in_period.by_path_and_status.page(params[:page]).order("count DESC")
               end
    end
  end

  def summary
    @sections = View::Hits::Category.all.reject { |c| c.name == "all" }.map do |category|
      category.tap do |c|
        c.hits = hits_in_period.by_path_and_status.send(category.to_sym).top_ten.to_a
      end
    end

    unless @period.single_day?
      @point_categories = View::Hits::Category.all.map do |category|
        category.tap do |c|
          c.points = (c.name == "all" ? totals_in_period : totals_in_period.send(category.to_sym))
        end
      end
    end
  end

  def category
    @category = View::Hits::Category[params[:category]].tap do |c|
      c.hits   = hits_in_period.by_path_and_status.send(c.to_sym).page(params[:page]).order("count DESC")
      c.points = totals_in_period.by_date_and_status.send(c.to_sym)
    end
  end

  def universal_summary
    @sections = View::Hits::Category.all.reject { |c| c.name == "all" }.map do |category|
      category.tap do |c|
        c.hits = hits_in_period.by_host_and_path_and_status.send(category.to_sym).top_ten.to_a
      end
    end
  end

  def universal_category
    # Category - one of %w(archives redirect errors) (see routes.rb)
    @category = View::Hits::Category[params[:category]].tap do |c|
      c.hits = hits_in_period.by_host_and_path_and_status.send(c.to_sym).page(params[:page]).order("count DESC")
    end
  end

protected

  def set_period
    @period = (View::Hits::TimePeriod[params[:period]] || View::Hits::TimePeriod.default)
  end

  def hits_in_period
    if @site
      @site.hits.in_range(@period.start_date, @period.end_date)
        .includes(:mapping, host: :site)
    else
      Hit.in_range(@period.start_date, @period.end_date).includes(:mapping, :host)
    end
  end

  def totals_in_period
    @site.daily_hit_totals.by_date.in_range(@period.start_date, @period.end_date)
  end
end
