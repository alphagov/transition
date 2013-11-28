class Organisation < ActiveRecord::Base
  attr_accessible :title, :launch_date, :homepage, :furl, :css

  belongs_to :parent, class_name: Organisation, foreign_key: 'parent_id'

  has_many :sites
  has_many :hosts, through: :sites
  has_many :mappings, through: :sites

  validates_presence_of :redirector_abbr
  validates_presence_of :title
  validates_uniqueness_of :redirector_abbr

  def to_param
    redirector_abbr
  end
end
