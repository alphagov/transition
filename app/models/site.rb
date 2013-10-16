class Site < ActiveRecord::Base
  belongs_to :organisation

  has_many :hosts
  has_many :mappings
  has_many :hits, through: :hosts

  validates_presence_of :abbr
  validates_uniqueness_of :abbr

  def aggregated_hits
    hits.aggregated
  end

  def to_param
    abbr
  end

  def default_host
    hosts.first
  end
end
