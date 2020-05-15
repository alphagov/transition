require "kaminari"

class Hit < ApplicationRecord
  NEVER = Date.new(1970, 1, 1)

  belongs_to :host
  belongs_to :mapping

  validates :host, :hit_on, presence: true
  validates :path, presence: true, length: { maximum: 1024 }
  validates :count, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :http_status, presence: true, length: { maximum: 3 }
  validates :host_id, uniqueness: { scope: %i[path hit_on http_status], message: "Hit data already exists for this host, path, date and status!" }

  before_validation :normalize_hit_on

  scope :by_host_and_path_and_status,
        lambda {
          select("hits.path AS path, sum(hits.count) as count, hits.host_id, "\
                 "hits.http_status, MIN(hits.mapping_id) as mapping_id")
            .group(:path, :http_status, :host_id)
        }
  scope :by_path_and_status,
        lambda {
          select("hits.path, sum(hits.count) as count, hits.http_status,"\
                 "MIN(hits.mapping_id) AS mapping_id, MIN(hits.host_id) AS host_id")
            .group(:path, :http_status)
        }
  scope :in_range, ->(start_date, end_date) { where("(hit_on >= ?) AND (hit_on <= ?)", start_date, end_date) }

  scope :errors,     -> { where(http_status: "404") }
  scope :archives,   -> { where(http_status: "410") }
  scope :redirects,  -> { where(http_status: "301") }
  scope :top_ten,    -> { order("count DESC").limit(10) }

  def error?
    http_status == "404"
  end

  def archive?
    http_status == "410"
  end

  def redirect?
    http_status == "301"
  end

  def homepage?
    path == "/" || path.starts_with?("/?")
  end

  def default_url
    "http://#{host.site.default_host.hostname}#{path}"
  end

protected

  def normalize_hit_on
    self.hit_on = hit_on.beginning_of_day if saved_change_to_hit_on?
  end
end
