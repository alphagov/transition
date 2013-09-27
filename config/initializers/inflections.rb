# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
#
ActiveSupport::Inflector.inflections do |inflect|
  # Careful with this - it changes all conventions around fields
  # like :archive_url or :http_status, meaning things like validators
  # have to be renamed, e.g. NonBlankUrlValidator -> NonBlankURLValidator
  inflect.acronym 'HTTP'
  inflect.acronym 'URL'
end
