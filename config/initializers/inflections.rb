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
# These inflection rules are supported but not enabled by default:
#ActiveSupport::Inflector.inflections do |inflect|
#   inflect.acronym 'HTTP'
#   inflect.acronym 'URL'
#end

# ... and now we know why, because it changes autoload behaviour. Got a class called
# oh, let's see, NonBlankUrlValidator? Change this inflection and now it needs to be
# NonBlankURLValidator. Multiply this up over any number of gems that might rely on this convention
# and it's too risky. Look at +ApplicationHelper#titleize_known_abbr+ instead.
