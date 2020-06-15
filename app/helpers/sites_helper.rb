module SitesHelper
  include MappingsHelper

  def big_launch_days_number(site)
    return nil if site.launch_date.nil?

    big_day_span = tag.div(
      pluralize(days_before_or_after_launch(site), "day"),
      class: "big-number",
    )

    should_have_launched = Time.zone.today > site.launch_date
    small_text = tag.div(
      if site.transition_status == :live
        "since transition"
      elsif should_have_launched
        case site.transition_status
        when :indeterminate  then "since transition"
        when :pre_transition then "overdue"
        end
      else
        "until transition"
      end,
    )

    big_day_span + " " + small_text
  end

  def days_before_or_after_launch(site)
    (site.launch_date - Date.current).to_i.abs
  end

  def site_redirects_link(site)
    link_to pluralize(number_with_delimiter(site.mappings.redirects.count), "redirect"),
            site_mappings_path(site_id: site, type: "redirect"),
            class: "link-muted"
  end

  def site_archives_link(site)
    link_to pluralize(number_with_delimiter(site.mappings.archives.count), "archive"),
            site_mappings_path(site_id: site, type: "archive"),
            class: "link-muted"
  end

  def site_unresolved_link(site)
    link_to "#{number_with_delimiter(site.mappings.unresolved.count)} unresolved",
            site_mappings_path(site_id: site, type: "unresolved"),
            class: "link-muted"
  end

  def site_unresolved_mappings_percentage(site)
    if site.mappings.unresolved.count.positive? && site.mappings.count.positive?
      friendly_hit_percentage((site.mappings.unresolved.count.to_f / site.mappings.count) * 100)
    else
      "0%"
    end
  end
end
