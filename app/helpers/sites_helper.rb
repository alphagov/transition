module SitesHelper
  def big_launch_days_number(site)
    big_day_span = content_tag(
      :span,
      pluralize(days_before_or_after_launch(site), 'day'),
      class: 'big-number'
    )

    should_have_launched = Date.today > site.launch_date
    small_text = if should_have_launched
                   site.transition_status == :pre_transition ?
                     'overdue' :
                     'since transition'
                 else
                   'until transition'
                 end

    big_day_span + ' ' + small_text
  end

  def days_before_or_after_launch(site)
    (site.launch_date - DateTime.now.midnight.utc).to_i.abs
  end
end
