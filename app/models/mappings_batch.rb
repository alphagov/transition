class MappingsBatch < ActiveRecord::Base
  attr_accessor :paths # a virtual attribute to then use for creating entries

  belongs_to :user
  belongs_to :site
  has_many :mappings_batch_entries

  validates :user, presence: true
  validates :site, presence: true
  validates :http_status, inclusion: { :in => Mapping::SUPPORTED_STATUSES }
  validates :new_url, presence: { if: :redirect?, message: 'required when mapping is a redirect' }
  validates :new_url, length: { maximum: (64.kilobytes - 1) }, non_blank_url: true
  validates :paths, presence: true
  validate :paths, :paths_cannot_include_hosts_for_another_site, :paths_cannot_be_empty_once_canonicalised

  before_validation :fill_in_scheme

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
    canonical_paths = paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
    if canonical_paths.empty?
      errors.add(:paths, I18n.t('mappings.bulk.add.paths_empty'))
    end
  end
end
