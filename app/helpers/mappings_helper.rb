module MappingsHelper
  def example_url(mapping, options = {})
    scheme_and_host = 'http://'+ mapping.site.default_host.hostname
    link_to (options[:include_host] ? scheme_and_host : '') + mapping.path, scheme_and_host + mapping.path
  end
end
