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
    (site.launch_date - Date.current).to_i.abs
  end

  def site_redirects_link(site)
    link_to pluralize(number_with_delimiter(site.mappings.redirects.count), 'redirect'),
      site_mappings_path(site, type: 'redirect'),
      class: 'link-muted'
  end

  def site_archives_link(site)
    link_to pluralize(number_with_delimiter(site.mappings.archives.count), 'archive'),
      site_mappings_path(site, type: 'archive'),
      class: 'link-muted'
  end

  def site_unresolved_link(site)
    link_to "#{number_with_delimiter(site.mappings.unresolved.count)} unresolved",
      site_mappings_path(site, type: 'unresolved'),
      class: 'link-muted'
  end

  def site_unresolved_mappings_percentage(site)
    if site.mappings.unresolved.count > 0 && site.mappings.count > 0
      friendly_hit_percentage((site.mappings.unresolved.count.to_f / site.mappings.count) * 100)
    else
      '0%'
    end
  end

  def hits_last_calendar_month(hosts)
    hits = hosts.collect do |host|
      host.hits.select do |hit|
        hit.hit_on >= Date.today.beginning_of_month - 1.month &&
          hit.hit_on < Date.today.beginning_of_month
      end
    end.flatten
    hits.inject(0) { |sum,hit| sum + hit.count }
  end

  def hits_this_calendar_month(hosts)
    hits = hosts.collect do |host|
      host.hits.select do |hit|
        hit.hit_on >= Date.today.beginning_of_month
      end
    end.flatten
    hits.inject(0) { |sum,hit| sum + hit.count }
  end
end
