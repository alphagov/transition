require 'digest/sha1'
class Mapping < ActiveRecord::Base
  attr_accessible :c14d_path, :site

  belongs_to :site
  validates :site, presence: true
  validates :c14d_path, presence: true, length: { maximum: 1024 }
  validates :http_status, presence: true, length: { maximum: 3 }
  validates :site_id, uniqueness: { scope: [:c14d_path], message: 'Mapping already exists for this site and path!' }

  # set a hash of the path because we can't have a unique index on
  # the path (it's too long)
  before_validation :set_path_hash
  validates :c14d_hash, presence: true

  validates :new_url, :suggested_url, :archive_url, length: { maximum: (64.kilobytes - 1) }

  scope :with_status, -> status { where(http_status: Rack::Utils.status_code(status)) }
  scope :redirects, with_status(:moved_permanently)

  protected
  def set_path_hash
    self.c14d_hash = Digest::SHA1.hexdigest(c14d_path) if c14d_path_changed?
  end
end
