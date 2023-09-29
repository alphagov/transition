class SiteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :site_id

  attribute :organisation_slug
  attribute :abbr
  attribute :tna_timestamp
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

  def self.for_existing(site)
    new(
      site_id: site.id,
      organisation_slug: site.organisation.whitehall_slug,
      abbr: site.abbr,
      tna_timestamp: site.tna_timestamp.to_formatted_s(:number),
      homepage: site.homepage,
      extra_organisations: site.extra_organisations,
      homepage_title: site.homepage_title,
      homepage_furl: site.homepage_furl,
      global_type: site.global_type,
      global_new_url: site.global_new_url,
      global_redirect_append_path: site.global_redirect_append_path,
      query_params: site.query_params,
      special_redirect_strategy: site.special_redirect_strategy,
      hostname: site.default_host.hostname,
      aliases: site.hosts_excluding_primary_and_aka.map(&:hostname).join(","),
    )
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      site.save!
      hosts.each(&:save!)
      aka_hosts.each(&:save!)
      destroy_removed_hosts
    end

    site
  end

  def organisations
    Organisation.where.not(whitehall_slug: organisation_slug)
  end

private

  def site
    @site ||= Site.find_or_initialize_by(id: site_id).tap do |site|
      site.assign_attributes(
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
  end

  def hosts
    [default_host].concat(alias_hosts)
  end

  def aka_hosts
    hosts.map { |host| build_aka_host(host) }
  end

  def default_host
    @default_host ||= Host.find_or_initialize_by(hostname:, site:).tap do |host|
      host.assign_attributes(hostname:, site:)
    end
  end

  def alias_hosts
    return [] if aliases.nil?

    @alias_hosts ||= aliases.split(",").map do |host|
      Host.find_or_initialize_by(hostname: host, site:)
    end
  end

  def build_aka_host(host)
    Host.find_or_initialize_by(hostname: host.aka_hostname, canonical_host: host, site:)
  end

  def destroy_removed_hosts
    site.hosts
        .reject { |host| hosts.map(&:hostname).include?(host.hostname) }
        .reject { |host| aka_hosts.map(&:hostname).include?(host.hostname) }
        .each(&:destroy)
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
        errors.add(:aliases, error.message)
      end
    end
  end

  def aliases_are_unique
    if alias_hosts.length != alias_hosts.map(&:hostname).uniq.length
      errors.add(:aliases, :not_unique)
    end
  end
end
