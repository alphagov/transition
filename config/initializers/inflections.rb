# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections do |inflect|
  # Careful with this - it changes all conventions around fields
  # like :archive_url or :http_status, meaning things like validators
  # have to be renamed, e.g. NonBlankUrlValidator -> NonBlankURLValidator
  inflect.acronym "HTTP"
  inflect.acronym "URL"
  inflect.acronym "URLs"
  inflect.uncountable "unresolved"
end
