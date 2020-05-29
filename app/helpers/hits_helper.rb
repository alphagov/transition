module HitsHelper
  def any_totals_for?(points_categories)
    points_categories && points_categories.find { |c| c.points.present? }
  end

  def no_hits_for_any?(sections)
    sections.all? { |section| section.hits.none? }
  end

  ##
  # Given a list of #View::Hits::Category# with populated points,
  # produces a Google data table JSON representation, as defined at:
  #
  # https://developers.google.com/chart/interactive/docs/dev/implementing_data_source?hl=pt-BR#jsondatatable
  #
  # Note: Google uses a custom JSON date format, a string in the form of:
  # Date(year, month, day)
  #
  # eg google_data_table([Category.new('errors'), Category.new('archives')])
  # {
  #   cols: [{label: 'Date', type: 'date'},
  #          {label: 'Errors', type: 'number'},
  #          {label: 'Archive', type: 'number'}],
  #   rows: [
  #          {c:[{v: 'Date(2012, 11, 10)'}, {v: ''}, {v: 10000, f:'10,000'}, {v: 20000, f:'20,000'}]},
  #          {c:[{v: 'Date(2012, 11, 11)'}, {v: ''}, {v: 1000,  f:'1,000'}, {v: 2000, f:'2,000'}]},
  #         ]
  # }
  #
  # Example showing a vertical line on x-axis
  # https://groups.google.com/forum/#!topic/google-visualization-api/cfG-iqZSfds
  # http://savedbythegoog.appspot.com/?id=7e54024673afee6264407cc6c21f99f3a6b160ad
  #
  def google_data_table(categories, site = nil)
    transition_date = site && site.transition_status == :live ? site.launch_date : nil
    dates = {}
    cols  = [
      { label: "Date", type: "date" },
      { label: "Transition date line", type: "string", p: { role: "annotation" } },
    ]

    categories.each do |category|
      cols << { label: category.title, type: "number" }

      category.points.each do |total|
        date                = dates[total.total_on] || (dates[total.total_on] = {})
        date[category.name] = total.count
      end
    end

    rows = []
    dates.each_pair do |date, category_counts|
      rows << {
        c: [
          { v: "Date(#{date.year}, #{date.month - 1}, #{date.day})" },
          { v: date == transition_date ? "Transition" : nil },
          *categories.map do |c|
            count_for_category = category_counts[c.name] || 0
            { v: count_for_category, f: number_with_delimiter(count_for_category) }
          end,
        ],
      }
    end

    { cols: cols, rows: rows }.to_json.html_safe
  end

  def colors(point_categories)
    point_categories.map(&:color).to_s.html_safe
  end

  def http_status_for(mapping)
    if mapping.redirect?
      "301"
    elsif mapping.archive? || mapping.unresolved?
      "410"
    end
  end

  def show_hit_has_become?(hit)
    ((hit.archive? || hit.error?) && hit.mapping.redirect?) ||
      ((hit.redirect? || hit.error?) && hit.mapping.archive?)
  end

  def hit_is_now(hit)
    if hit.archive? && hit.mapping.redirect?
      "was archived, now redirecting"
    elsif hit.redirect? && hit.mapping.archive?
      "was redirecting, now archived"
    elsif hit.error? && hit.mapping.redirect?
      '<span class="middle-grey">Error fixed</span> &mdash; now redirecting'.html_safe
    elsif hit.error? && hit.mapping.archive?
      '<span class="middle-grey">Error fixed</span> &mdash; now archived'.html_safe
    end
  end

  def hit_has_unresolved_mapping
    '<span class="middle-grey">Unresolved</span> &mdash; needs a decision'.html_safe
  end

  ##
  # Send the correct routing message for the current category and period
  def current_category_in_period_path(site, period)
    if site
      current_category_of_hits_for_specific_site(site, period)
    else
      current_category_of_hits_for_universal_analytics(period)
    end
  end

  def viewing_all_hits?
    action_name == "index"
  end

private

  def current_category_of_hits_for_specific_site(site, period)
    # Hits for a specific site
    if params[:category]
      category_site_hits_path(site, category: params[:category], period: period.query_slug)
    elsif viewing_all_hits?
      site_hits_path(site, period: period.query_slug)
    else
      summary_site_hits_path(site, period: period.query_slug)
    end
  end

  def current_category_of_hits_for_universal_analytics(period)
    # Universal analytics
    if params[:category]
      hits_category_path(category: params[:category], period: period.query_slug)
    else
      hits_path(period: period.query_slug)
    end
  end
end
