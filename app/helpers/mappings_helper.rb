module MappingsHelper
  def example_url(mapping, options = {})
    scheme_and_host = 'http://'+ mapping.site.default_host.hostname
    link_to (options[:include_host] ? scheme_and_host : '') + mapping.path, scheme_and_host + mapping.path
  end

  def bootstrap_tabs(link_hash, options)
    content_tag :ul, class: 'nav nav-tabs' do
      link_hash.inject('') do |result, arr|
        title, link_proc  = arr[0], arr[1]
        active            = options[:active] == title
        html_opts         = {}
        html_opts[:class] = 'active' if active

        result << content_tag(:li, html_opts) do
          link_to(title, active ? '#' : link_proc.call)
        end
      end.html_safe
    end
  end

  def mapping_edit_tabs(options = {})
    if @mapping.versions.any?
      bootstrap_tabs(
        {
          'Edit'    => lambda { edit_site_mapping_path(@mapping.site, @mapping) },
          'History' => lambda { site_mapping_versions_path(@mapping.site, @mapping) }
        },
        options)
    end
  end
end
