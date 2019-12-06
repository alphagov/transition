class NonBlankURLValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    valid_url = begin
      uri = Addressable::URI.parse(value)
      uri.scheme.present? && uri.host.present? && uri.host.include?(".")
                rescue Addressable::URI::InvalidURIError
                  false
    end
    record.errors.add attribute, (options[:message] || "is not a URL") unless valid_url
  end
end
