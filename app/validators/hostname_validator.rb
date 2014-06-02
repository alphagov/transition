class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    valid = begin
      URI.parse("http://#{value}").host == value
    rescue URI::InvalidURIError
      false
    end

    unless valid
      record.errors[attribute] << 'is an invalid hostname'
    end
  end
end
