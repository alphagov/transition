class NotANationalArchivesURLValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    if value.include?('http://webarchive.nationalarchives.gov.uk')
      message = (options[:message])
      record.errors.add(attribute, message)
    end
  end
end
