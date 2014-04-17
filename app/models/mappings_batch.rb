class MappingsBatch < ActiveRecord::Base
  attr_accessor :paths # a virtual attribute to then use for creating entries

  belongs_to :user
  belongs_to :site
  has_many :mappings_batch_entries
  has_many :entries, foreign_key: :mappings_batch_id, class_name: 'MappingsBatchEntry'

  validates :user, presence: true
  validates :site, presence: true
  validates :http_status, inclusion: { :in => Mapping::SUPPORTED_STATUSES }
  validates :new_url, presence: { if: :redirect?, message: 'required when mapping is a redirect' }
  validates :new_url, length: { maximum: (64.kilobytes - 1) }, non_blank_url: true
  validates :paths, presence: true
  validate :paths, :paths_cannot_include_hosts_for_another_site, :paths_cannot_be_empty_once_canonicalised

  before_validation :fill_in_scheme

  after_create :create_entries

  def redirect?
    http_status == '301'
  end

  def fill_in_scheme
    self.new_url = Mapping.ensure_url(new_url)
  end

  def paths_cannot_include_hosts_for_another_site
    return true if paths.blank?
    hosts = paths.grep(/^http/).map do |url|
      uri = URI.parse(url)
      uri.host
    end
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
    entries.each do |entry|
      mapping = site.mappings.where(path: entry.path).first_or_initialize

      next if !update_existing && mapping.persisted?

      mapping.http_status = http_status
      mapping.new_url = new_url
      mapping.tag_list = [mapping.tag_list, tag_list].join(',')
      mapping.save
    end
  end

private
  def canonical_paths
    @_canonical_paths = paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
  end
end
