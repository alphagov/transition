class BulkAddBatch < MappingsBatch
  attr_accessor :paths # a virtual attribute to then use for creating entries

  attr_accessible :paths, :type, :new_url

  validates :paths, presence: { :if => :new_record?, message: I18n.t('mappings.bulk.add.paths_empty') } # we only care about paths at create-time
  validate :paths_cannot_include_hosts_for_another_site, :paths_cannot_be_empty_once_canonicalised
  validates :type, inclusion: { :in => Mapping::SUPPORTED_TYPES }
  with_options :if => :redirect? do |redirect|
    redirect.validates :new_url, presence: { message: I18n.t('mappings.bulk.new_url_invalid') }
    redirect.validates :new_url, length: { maximum: (64.kilobytes - 1) }
    redirect.validates :new_url, non_blank_url: { message: I18n.t('mappings.bulk.new_url_invalid') }
    redirect.validates :new_url, host_in_whitelist: { message: I18n.t('mappings.bulk.new_url_must_be_on_whitelist', email: Rails.configuration.support_email) }
  end

  before_validation :fill_in_scheme
  after_create :create_entries

  def fill_in_scheme
    self.new_url = Mapping.ensure_url(new_url)
  end

  def redirect?
    type == 'redirect'
  end

  def paths_cannot_include_hosts_for_another_site
    return true if paths.blank?
    hosts = paths.grep(/^http/).map do |url|
      begin
        uri = Addressable::URI.parse(url)
        uri.host
      rescue Addressable::URI::InvalidURIError
        errors.add(:paths, "Old URLs includes an invalid URL: #{url}")
      end
    end
    hosts.uniq!

    if hosts.any? && (hosts.size != site.hosts.where(hostname: hosts).count)
      errors.add(:paths, I18n.t('mappings.bulk.add.hosts_invalid'))
    end
  end

  def paths_cannot_be_empty_once_canonicalised
    return true if paths.blank?
    if canonical_paths.empty?
      errors.add(:paths, I18n.t('mappings.bulk.add.paths_empty'))
    end
  end

  # called after_create, so in the same transaction
  def create_entries
    canonical_path_hashes = canonical_paths.map { |path| Digest::SHA1.hexdigest(path) }
    existing_mappings = site.mappings.where(path_hash: canonical_path_hashes)

    records = canonical_paths.map do |canonical_path|
      entry = MappingsBatchEntry.new(path: canonical_path)
      entry.mappings_batch = self
      path_hash = Digest::SHA1.hexdigest(canonical_path)
      entry.mapping = existing_mappings.detect { |mapping| mapping.path_hash == path_hash }
      entry
    end

    MappingsBatchEntry.import(records, validate: false)
  end

  def process
    with_state_tracking do
      entries.each do |entry|
        path_hash = Digest::SHA1.hexdigest(entry.path)
        mapping = site.mappings.where(path_hash: path_hash).first_or_initialize

        next if !update_existing && mapping.persisted?
        mapping.path = entry.path
        mapping.type = type
        mapping.new_url = new_url
        mapping.tag_list = [mapping.tag_list, tag_list].join(',')
        mapping.save

        entry.update_column(:processed, true)
      end
    end
  end

private
  def canonical_paths
    @_canonical_paths ||= paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
  end
end
