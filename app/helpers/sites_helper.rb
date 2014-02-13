module SitesHelper
  def big_launch_days_number(site)
    return nil if site.launch_date.nil?

    big_day_span = content_tag(
      :div,
      pluralize(days_before_or_after_launch(site), 'day'),
      class: 'big-number'
    )

    should_have_launched = Date.today > site.launch_date
    small_text = content_tag(
      :div,
      if site.transition_status == :live
        'since transition'
      elsif should_have_launched
        case site.transition_status
        when :indeterminate  then 'since transition'
        when :pre_transition then 'overdue'
        end
      else
        'until transition'
      end
    )

    big_day_span + ' ' + small_text
  end

  def days_before_or_after_launch(site)
    (site.launch_date - DateTime.now.midnight.utc).to_i.abs
  end

  def mappings_edit_or_view
    current_user.can_edit?(@site.organisation) ? 'Edit' : 'View'
  end
end
