class IsPathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(
        attribute,
        "can't be blank",
      ) && return
    end
    if /^[^\/]/.match?(value)
      record.errors.add(
        attribute,
        'must start with a forward slash "/"',
      ) && return
    end

    valid_path = begin
      Addressable::URI.parse(value).relative?
                 rescue Addressable::URI::InvalidURIError
                   false
    end

    unless valid_path
      record.errors.add attribute,
                        'contains invalid or unsafe characters (e.g. "<")'
    end
  end
end
