class Site < ActiveRecord::Base
  belongs_to :organisation

  has_many :hosts
  has_many :mappings

  validates_presence_of :abbr
  validates_uniqueness_of :abbr

  def to_param
    abbr
  end
end
