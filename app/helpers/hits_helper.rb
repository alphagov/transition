module HitsHelper
  def link_to_hit(hit)
    scheme_and_host = 'http://'+ hit.host.hostname
    link_to hit.path, scheme_and_host + hit.path
  end

  ##
  # Given a list of #Transition::Hits::Category# with populated points,
  # produce a raw JS-compatible array of the form:
  #
  # e.g. raw_summary_array([Category.new('all'), Category.new('archives')])
  # [
  #   ["Date", "All hits", "Archives"]
  #   ["2013-08-08", 121, 77]
  #   ["2013-08-09", 343, 12]
  # ]
  def raw_summary_array(point_categories)
    header = ['Date'].concat(point_categories.map(&:title))

    [header].tap do |array|
      dates = {}

      point_categories.each do |category|
        category.points.each do |hit|
          date = dates[hit.hit_on.strftime('%Y-%m-%d')] ||= {}
          date[category.name] = hit.count
        end
      end

      dates.each_pair do |date, category_counts|
        array << [date, *point_categories.map {|c| category_counts[c.name] || 0}]
      end
    end.to_s.html_safe
  end

  def colors(point_categories)
    point_categories.map(&:color).to_s.html_safe
  end
end
