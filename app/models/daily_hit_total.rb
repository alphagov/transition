class DailyHitTotal < ActiveRecord::Base
  belongs_to :host

  scope :in_range, ->(start_date, end_date) { where('(total_on >= ?) AND (total_on <= ?)', start_date, end_date) }

  scope :by_date, -> { select('sum(count) as count, total_on').group(:total_on) }
  scope :by_date_and_status, -> { select('sum(count) as count, total_on').group(:total_on, :http_status) }

  scope :errors,     -> { where(http_status: 404) }
  scope :archives,   -> { where(http_status: 410) }
  scope :redirects,  -> { where(http_status: 301) }
  scope :other,      -> { where('http_status NOT IN (?)', [404, 410, 301]) }
end
