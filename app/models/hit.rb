require 'digest/sha1'
require 'kaminari'

class Hit < ActiveRecord::Base
  NEVER = Date.new(1970, 1, 1)

  belongs_to :host
  belongs_to :mapping

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

  scope :by_path_and_status, -> {
    select('hits.path, sum(hits.count) as count, hits.http_status').
      group(:path_hash, :http_status)
  }
  scope :points_by_date, -> {
    select('hits.hit_on, sum(hits.count) as count').group(:hit_on)
  }
  scope :points_by_date_and_status, -> {
    select('hits.hit_on, sum(hits.count) as count, hits.http_status').
      group(:hit_on, :http_status)
  }
  scope :in_range, ->(start_date, end_date) { where('(hit_on >= ?) AND (hit_on <= ?)', start_date, end_date) }

  scope :errors,     -> { where(http_status: '404') }
  scope :archives,   -> { where(http_status: '410') }
  scope :redirects,  -> { where(http_status: '301') }
  scope :top_ten,    -> { order('count DESC').limit(10) }

  protected
  def set_path_hash
    self.path_hash = Digest::SHA1.hexdigest(path) if path_changed?
  end
  def normalize_hit_on
    self.hit_on = hit_on.beginning_of_day if hit_on_changed?
  end
end
