require 'active_record/concerns/nilify_blanks'
require 'digest/sha1'

class Mapping < ActiveRecord::Base
  include ActiveRecord::Concerns::NilifyBlanks

  SUPPORTED_STATUSES = [301, 410]

  attr_accessible :path, :site, :http_status, :new_url, :suggested_url, :archive_url

  has_paper_trail

  belongs_to :site
  validates :site, presence: true
  validates :path,
            presence: true,
            length: { maximum: 1024 },
            exclusion: { in: ['/'], message: I18n.t('not_possible_to_edit_homepage_mapping')}
  validates :http_status, presence: true, length: { maximum: 3 }
  validates :site_id, uniqueness: { scope: [:path], message: 'Mapping already exists for this site and path!' }

  # set a hash of the path because we can't have a unique index on
  # the path (it's too long)
  before_validation :canonicalize_path, :set_path_hash
  validates :path_hash, presence: true

  validates :new_url, :suggested_url, :archive_url, length: { maximum: (64.kilobytes - 1) }, non_blank_url: true
  validates :new_url, presence: { if: :redirect?, message: 'required when mapping is a redirect' }

  scope :with_status, -> status { where(http_status: Rack::Utils.status_code(status)) }
  scope :redirects, with_status(:moved_permanently)
  scope :filtered_by_path, -> path { where(path.blank? ? true : Mapping.arel_table[:path].matches("%#{path}%")) }

  def redirect?
    http_status == '301'
  end

  protected
  def set_path_hash
    self.path_hash = Digest::SHA1.hexdigest(path) if path_changed?
  end

  def canonicalize_path
    self.path = site.canonicalize_path(path) unless (site.nil? || path == '/')
  end
end
