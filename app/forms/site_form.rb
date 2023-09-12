class SiteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :organisation_slug
  attribute :abbr
  attribute :tna_timestamp, :datetime
  attribute :homepage
  attribute :homepage_title
  attribute :extra_organisations
  attribute :global_type
  attribute :global_new_url
  attribute :homepage_furl
  attribute :query_params
  attribute :global_redirect_append_path, :boolean, default: false
  attribute :special_redirect_strategy

  attribute :hostname
  attribute :aliases

  validate :validate_children
  validate :validate_aliases
  validate :aliases_are_unique

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      site.save!
      hosts.each(&:save!)
      aka_hosts.each(&:save!)
    end

    site
  end

  def organisations
    Organisation.where.not(whitehall_slug: organisation_slug)
  end

private

  def site
    @site ||= Site.new(
      abbr:,
      tna_timestamp:,
      homepage:,
      organisation: Organisation.find_by(whitehall_slug: organisation_slug),
      extra_organisations: Organisation.where(id: extra_organisations),
      homepage_title:,
      homepage_furl:,
      global_type:,
      global_new_url:,
      global_redirect_append_path:,
      query_params:,
      special_redirect_strategy:,
    )
  end

  def hosts
    [default_host].concat(alias_hosts)
  end

  def aka_hosts
    hosts.map { |host| build_aka_host(host) }
  end

  def default_host
    @default_host ||= Host.new(hostname:, site:)
  end

  def alias_hosts
    return [] if aliases.nil?

    @alias_hosts ||= aliases.split(",").map do |host|
      Host.new(hostname: host, site:)
    end
  end

  def build_aka_host(host)
    Host.new(hostname: host.aka_hostname, canonical_host: host, site:)
  end

  def validate_children
    [site, default_host].each do |child|
      errors.merge!(child.errors) if child.invalid?
    end
  end

  def validate_aliases
    alias_hosts.each do |host|
      next if host.valid?

      host.errors.each do |error|
        errors.add(:aliases, "\"#{host.hostname}\" #{error.message}")
      end
    end
  end

  def aliases_are_unique
    if alias_hosts.length != alias_hosts.map(&:hostname).uniq.length
      errors.add(:aliases, "must be unique")
    end
  end
end
