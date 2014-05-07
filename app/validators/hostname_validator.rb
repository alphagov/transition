class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    if URI.parse("http://#{value}").host != value
      record.errors[attribute] << 'is an invalid hostname'
    end
  end
end
