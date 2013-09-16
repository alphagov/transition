class NonBlankUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    valid_url = false
    begin
      uri = URI.parse(value)
      valid_url = !uri.scheme.blank? && !uri.host.blank?
    rescue URI::InvalidURIError
      # ignore
    end
    record.errors.add attribute, (options[:message] || 'is not a URL') unless valid_url
  end
end
