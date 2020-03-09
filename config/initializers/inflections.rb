# Be sure to restart your server when you modify this file.

ActiveSupport::Inflector.inflections(:en) do |inflect|
  # Careful with this - it changes all conventions around fields
  # like :archive_url or :http_status, meaning things like validators
  # have to be renamed, e.g. NonBlankUrlValidator -> NonBlankURLValidator
  inflect.acronym "HTTP"
  inflect.acronym "URL"
  inflect.acronym "URLs"
  inflect.uncountable "unresolved"
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
