require 'digest/sha1'
require 'kaminari'

class Hit < ActiveRecord::Base
  NEVER = Date.new(1970, 1, 1)

  belongs_to :host
  validates :host, :hit_on, presence: true
  validates :path, presence: true, length: { maximum: 1024 }
  validates :count, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :http_status, presence: true, length: { maximum: 3 }
  validates :host_id, uniqueness: { scope: [:path, :hit_on, :http_status], message: 'Hit data already exists for this host, path, date and status!' }

  # set a hash of the path because we can't have a unique index on
  # the path (it's too long)
  before_validation :set_path_hash
  before_validation :normalize_hit_on
  validates :path_hash, presence: true

  def self.aggregated
    scoped.select('hits.path, sum(hits.count) as count, hits.http_status, hits.host_id').group(:path, :http_status)
  end

  protected
  def set_path_hash
    self.path_hash = Digest::SHA1.hexdigest(path) if path_changed?
  end
  def normalize_hit_on
    self.hit_on = hit_on.beginning_of_day if hit_on_changed?
  end
end
