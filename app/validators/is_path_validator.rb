class IsPathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute,
      "can't be blank" and return if value.blank?
    record.errors.add attribute,
      'must start with a forward slash "/"' and return if value =~ /^[^\/]/

    valid_path = begin
      Addressable::URI.parse(value).is_a?(Addressable::URI)
    rescue Addressable::URI::InvalidURIError
      false
    end

    record.errors.add attribute,
      'contains invalid or unsafe characters (e.g. "<")' unless valid_path
  end
end
