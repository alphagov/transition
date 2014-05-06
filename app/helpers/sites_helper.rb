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

  def site_global_http_status_text(site)
    if site.global_http_status == '301'
      "All paths from #{site.default_host.hostname}<br />
       <span class=\"text-muted\">redirect to #{site.global_new_url}</span>".html_safe
    elsif site.global_http_status == '410'
      "All paths from #{site.default_host.hostname}<br />
       <span class=\"text-muted\">have been archived</span>".html_safe
    end
  end

  def site_global_http_status_explanation(site)
    if site.global_http_status == '301' && site.global_redirect_append_path
      'The path the user visited is appended to the destination. <br /><br />' \
      "For example: <br />" \
      "http://#{site.default_host.hostname}<strong>/specific/path</strong> <br />" \
      "gets redirected to: <br />" \
      "#{site.global_new_url}<strong>/specific/path</strong> <br /><br />" \
      "To make changes please contact your Transition Manager.".html_safe
    elsif site.global_http_status == '301'
      I18n.t('mappings.global_http_status.redirect')
    elsif site.global_http_status == '410'
      I18n.t('mappings.global_http_status.archive')
    end
  end
end
