module FormHelper
  def error_messages(object)
    object.errors.group_by_attribute.map do |attribute, attribute_errors|
      error = attribute_errors.first
      {
        text: error.message,
        href: "##{field_id_attribute(object, attribute)}",
      }
    end
  end

  def error_message(object, field)
    object.errors.messages[field].first
  end

  def field_id_attribute(object, attribute)
    "#{object.class}_#{attribute}".underscore
  end

  def object_has_errors?(object)
    object.errors.any?
  end
end
