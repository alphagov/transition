module MappingsHelper
  ##
  # Twitter bootstrap-flavour tabs.
  # Produce a <ul class="nav nav-tabs">
  # with list items with links in them.
  # e.g.
  #
  #   +bootstrap_flavour_tabs(
  #      {
  #        'Edit'    => edit_path,
  #        'History' => history_path
  #      }, active: 'Edit'
  #    )
  def bootstrap_flavour_tabs(titles_to_links, options)
    tag.ul class: "nav nav-tabs" do
      titles_to_links.inject("") { |result, title_link|
        result << build_flavour_tab(title_link, options)
      }.html_safe
    end
  end

  def build_flavour_tab(title_link, options)
    title = title_link[0]
    href = title_link[1]
    active = options[:active] == title
    html_opts = {}
    html_opts[:class] = "active" if active

    tag.li(**html_opts) do
      link_to(title, active ? "#" : href)
    end
  end

  ##
  # Tabs for mapping editing
  def mapping_edit_tabs(mapping, options = {})
    if mapping.versions.any?
      tag.div class: "add-bottom-margin" do
        bootstrap_flavour_tabs(
          {
            "Edit" => edit_site_mapping_path(mapping.site, mapping),
            "History" => site_mapping_versions_path(mapping.site, mapping),
          },
          options,
        )
      end
    end
  end

  ##
  # Return a FormBuilder-compatible list of mapping types
  # e.g. [['Redirect', 'redirect'], ['Archive', 'archive'], ['Unresolved', 'unresolved']]
  def options_for_supported_types
    Mapping::SUPPORTED_TYPES.map do |type|
      [type.titleize.to_s, type]
    end
  end

  SUPPORTED_OPERATIONS = %w[tag] + Mapping::SUPPORTED_TYPES
  ##
  # Convert 'redirect'/'archive'/'tag' into 'Redirect'/'Archive'/'Tag'
  # to use in title and heading for edit_multiple
  def operation_name(operation)
    operation.titleize if SUPPORTED_OPERATIONS.include?(operation)
  end

  def new_confirmation_heading(type, count)
    if type == "unresolved"
      "Add #{number_with_delimiter(count)} unresolved #{'path'.pluralize(count)}"
    else
      "#{operation_name(type)} #{pluralize(number_with_delimiter(count), 'path')}"
    end
  end

  def friendly_hit_count(hit_count)
    hit_count ? number_with_delimiter(hit_count) : "0"
  end

  def friendly_hit_percentage(hit_percentage)
    if hit_percentage.zero? then ""
    elsif hit_percentage < 0.01 then "< 0.01%"
    elsif hit_percentage < 10.0 then hit_percentage.round(2).to_s + "%"
    else hit_percentage.round(1).to_s + "%"
    end
  end

  def show_preview_links?(site)
    site.default_host.aka_host &&
      site.default_host.aka_host.redirected_by_gds? &&
      site.hosts.excluding_aka.none?(&:redirected_by_gds?)
  end

  def side_by_side_url(site, mapping = nil)
    url = "http://#{site.default_host.hostname}.side-by-side.alphagov.co.uk/__/#"
    url << mapping.path if mapping
    url
  end
end
