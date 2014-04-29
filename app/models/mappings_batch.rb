class MappingsBatch < ActiveRecord::Base
  FINISHED_STATES = ['succeeded', 'failed']
  PROCESSING_STATES = ['unqueued', 'queued', 'processing'] + FINISHED_STATES

  attr_accessor :paths # a virtual attribute to then use for creating entries
  attr_accessible :paths, :http_status, :new_url, :tag_list, :update_existing, :state

  belongs_to :user
  belongs_to :site
  has_many :mappings_batch_entries
  has_many :entries, foreign_key: :mappings_batch_id, class_name: 'MappingsBatchEntry', dependent: :delete_all

  validates :user, presence: true
  validates :site, presence: true
  validates :http_status, inclusion: { :in => Mapping::SUPPORTED_STATUSES }
  with_options :if => :redirect? do |redirect|
    redirect.validates :new_url, presence: { message: I18n.t('mappings.bulk.new_url_invalid') }
    redirect.validates :new_url, length: { maximum: (64.kilobytes - 1) }
    redirect.validates :new_url, non_blank_url: { message: I18n.t('mappings.bulk.new_url_invalid') }
  end
  validates :paths, presence: { :if => :new_record?, message: I18n.t('mappings.bulk.add.paths_empty') } # we only care about paths at create-time
  validates :state, inclusion: { :in => PROCESSING_STATES }
  validate :paths_cannot_include_hosts_for_another_site, :paths_cannot_be_empty_once_canonicalised

  scope :reportable, where(seen_outcome: false).where("state != 'unqueued'")

  before_validation :fill_in_scheme

  after_create :create_entries

  def entries_to_process
    if update_existing
      entries
    else
      entries.without_existing_mappings
    end
  end

  def redirect?
    http_status == '301'
  end

  def type
    Mapping.type(http_status)
  end

  def finished?
    FINISHED_STATES.include?(state)
  end

  def succeeded?
    state == 'succeeded'
  end

  def failed?
    state == 'failed'
  end

  def fill_in_scheme
    self.new_url = Mapping.ensure_url(new_url)
  end

  def paths_cannot_include_hosts_for_another_site
    return true if paths.blank?
    hosts = paths.grep(/^http/).map do |url|
      begin
        uri = URI.parse(url)
        uri.host
      rescue URI::InvalidURIError
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
        mapping.http_status = http_status
        mapping.new_url = new_url
        mapping.tag_list = [mapping.tag_list, tag_list].join(',')
        mapping.save

        entry.update_column(:processed, true)
      end
    end
  end

  def with_state_tracking
    update_column(:state, 'processing')
    yield
    update_column(:state, 'succeeded')
  rescue => e
    update_column(:state, 'failed')
    raise
  end

private
  def canonical_paths
    @_canonical_paths = paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
  end
end
