class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    begin
      invalid = URI.parse("http://#{value}").host != value
    rescue URI::InvalidURIError
      invalid = true
    end
    if invalid
      record.errors[attribute] << 'is an invalid hostname'
    end
  end
end
