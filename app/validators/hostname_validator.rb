class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    valid = begin
      Addressable::URI.parse("http://#{value}").host == value
            rescue Addressable::URI::InvalidURIError
              false
    end

    unless valid
      record.errors[attribute] << "is an invalid hostname"
    end
  end
end
