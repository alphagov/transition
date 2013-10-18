module MappingsHelper
  def example_url(mapping, options = {})
    scheme_and_host = 'http://'+ mapping.site.default_host.hostname
    link_to (options[:include_host] ? scheme_and_host : '') + mapping.path, scheme_and_host + mapping.path
  end

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
    content_tag :ul, class: 'nav nav-tabs' do
      titles_to_links.inject('') do |result, title_link|
        title, href       = title_link[0], title_link[1]
        active            = options[:active] == title
        html_opts         = {}
        html_opts[:class] = 'active' if active

        result << content_tag(:li, html_opts) do
          link_to(title, active ? '#' : href)
        end
      end.html_safe
    end
  end

  ##
  # Tabs for mapping editing
  def mapping_edit_tabs(options = {})
    if @mapping.versions.any?
      bootstrap_flavour_tabs(
        {
          'Edit'    => edit_site_mapping_path(@mapping.site, @mapping),
          'History' => site_mapping_versions_path(@mapping.site, @mapping)
        },
        options)
    end
  end

  ##
  # Return a FormBuilder-compatible list of HTTP Status codes with descriptions
  # e.g. [['301 Moved Permanently', '301'], ['410 Gone', '410']]
  def options_for_supported_statuses
    Mapping::SUPPORTED_STATUSES.map do |status|
      ["#{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}", status.to_s]
    end
  end
end
