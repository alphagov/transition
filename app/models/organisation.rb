class Organisation < ActiveRecord::Base
  has_many :sites
  has_many :hosts, through: :sites
  has_many :mappings, through: :sites

  validates_presence_of :abbr
  validates_uniqueness_of :abbr

  def to_param
    abbr
  end
end
