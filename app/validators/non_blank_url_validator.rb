class NonBlankUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    record.errors.add attribute, (options[:message] || 'is not a URL') if
      URI.parse(value).scheme.blank? rescue true
  end
end
