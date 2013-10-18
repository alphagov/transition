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

  def aggregated_errors
    hits.aggregated_errors
  end

  def aggregated_archives
    hits.aggregated_archives
  end

  def aggregated_redirects
    hits.aggregated_redirects
  end
  
  def aggregated_other
    hits.aggregated_other
  end

  def to_param
    abbr
  end

  def default_host
    hosts.first
  end
end
