class Organisation < ActiveRecord::Base
  attr_accessible :title, :launch_date, :homepage, :furl, :css

  belongs_to :parent, class_name: Organisation, foreign_key: 'parent_id'

  has_many :sites
  has_many :hosts, through: :sites
  has_many :mappings, through: :sites

  validates_presence_of :abbr
  validates_uniqueness_of :abbr

  def to_param
    abbr
  end
end
