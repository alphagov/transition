class Organisation < ActiveRecord::Base
  has_many :sites
  has_many :hosts, through: :sites
  has_many :mappings, through: :sites

  def to_param
    abbr
  end
end
