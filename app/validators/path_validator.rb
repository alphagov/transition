class PathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      uri = URI.parse(value)
      valid_path = uri.is_a?(URI::Generic) && (uri.path =~ /^\/.*/)
    rescue URI::InvalidURIError
      valid_path = false
    end

    record.errors.add attribute, (options[:message] || 'is not a valid path') unless valid_path
  end
end
