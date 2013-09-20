module VersionsHelper
  def value_or_blank(value)
    value.blank? ? content_tag(:span, class: 'blank') { '<blank>' } : value
  end
end
