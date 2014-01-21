module SitesHelper
  def big_launch_days_number(site)
    content_tag(:span, pluralize(days_before_or_after_launch(site), 'day'), class: 'big-number') +
      (site.launch_date > Date.today ? ' until transition' : ' since transition')
  end

  def days_before_or_after_launch(site)
    (site.launch_date - DateTime.now.midnight.utc).to_i.abs
  end
end
