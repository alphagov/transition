class Host < ActiveRecord::Base
  belongs_to :site
  has_many :hits
  has_many :daily_hit_totals
end
