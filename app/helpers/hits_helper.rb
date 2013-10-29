require 'json'

module HitsHelper
  def link_to_hit(hit)
    scheme_and_host = 'http://'+ hit.host.hostname
    link_to hit.path, scheme_and_host + hit.path
  end

  ##
  # Given a list of #Transition::Hits::Category# with populated points,
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
  #          {c:[{v: 'Date(2012, 12, 10)'}, {v: 10000, f:'10,000'}, {v: 20000, f:'20,000'}]},
  #          {c:[{v: 'Date(2012, 12, 11)'}, {v: 1000,  f:'1,000'}, {v: 2000, f:'2,000'}]},
  #         ]
  # }
  def google_data_table(categories)

    dates = {}
    cols = [{label: 'Date', type: 'date'}]

    categories.each do |category|
      cols << {label: category.title, type: 'number'}

      category.points.each do |hit|
        date = dates[hit.hit_on] || dates[hit.hit_on] = {}
        date[category.name] = hit.count
      end
    end

    rows = []
    dates.each_pair do |date, category_counts|
      rows << {c: [
                {v: "Date(#{date.year}, #{date.month - 1}, #{date.day})"},
                *categories.map {|c| {v: category_counts[c.name] || 0, f: number_with_delimiter(category_counts[c.name] || 0)}}
              ]}
    end

    {cols: cols, rows: rows}.to_json.html_safe
  end

  def colors(point_categories)
    point_categories.map(&:color).to_s.html_safe
  end
end
