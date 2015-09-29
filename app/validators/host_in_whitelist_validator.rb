class HostInWhitelistValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    unless in_whitelist?(value)
      message = (options[:message] || "must be on a whitelisted domain. <a href='https://support.publishing.service.gov.uk/general_request/new'>Raise a support request through the GOV.UK Support form</a> for more information.")
      record.errors.add(attribute, message)
    end
  end

  def in_whitelist?(url)
    uri = Addressable::URI.parse(url)
    return false if uri.host.nil?
    uri.host.end_with?('.gov.uk') || uri.host.end_with?('.mod.uk') || uri.host.end_with?('.nhs.uk') || WhitelistedHost.exists?(hostname: uri.host)
  rescue Addressable::URI::InvalidURIError
  end
end
