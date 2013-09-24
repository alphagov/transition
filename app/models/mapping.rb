require 'active_record/concerns/nilify_blanks'
require 'digest/sha1'

class Mapping < ActiveRecord::Base
  include ActiveRecord::Concerns::NilifyBlanks

  SUPPORTED_STATUSES = [301, 410]
  
  attr_accessible :path, :site, :http_status, :new_url, :suggested_url, :archive_url

  paginates_per 100

  has_paper_trail

  belongs_to :site
  validates :site, presence: true
  validates :path, presence: true, length: { maximum: 1024 }
  validates :http_status, presence: true, length: { maximum: 3 }
  validates :site_id, uniqueness: { scope: [:path], message: 'Mapping already exists for this site and path!' }

  # set a hash of the path because we can't have a unique index on
  # the path (it's too long)
  before_validation :set_path_hash
  validates :path_hash, presence: true

  validates :new_url, :suggested_url, :archive_url, length: { maximum: (64.kilobytes - 1) }, non_blank_url: true
  validates :new_url, presence: { if: :redirect?, message: 'New URL required when mapping is a redirect' }

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
end
