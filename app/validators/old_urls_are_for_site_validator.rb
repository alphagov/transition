class OldURLsAreForSiteValidator < ActiveModel::EachValidator
  # old_urls may be relative or absolute
  def validate_each(record, attribute, old_urls)
    return if old_urls.blank?

    hosts = hosts_in_old_urls(old_urls)
    if hosts.any? && (hosts.size != record.site.hosts.where(hostname: hosts).count)
      record.errors.add(attribute, I18n.t("mappings.hosts_invalid"))
    end
  end

  def hosts_in_old_urls(old_urls)
    hosts = old_urls.grep(::Transition::PathOrUrl::STARTS_WITH_HTTP_SCHEME).map do |url|
      uri = Addressable::URI.parse(url)
      uri.host
    rescue Addressable::URI::InvalidURIError
      record.errors.add(attribute, "Old URLs includes an invalid URL: #{url}")
    end
    hosts.uniq
  end
end
