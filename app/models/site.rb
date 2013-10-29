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

  def canonicalize_path(raw_path)
    # BLURI takes a full URL, but we only care about the path. There's no
    # benefit in making an extra query to get a real hostname for the site.
    raw_url = 'http://www.example.com' + raw_path
    bluri = BLURI(raw_url).canonicalize!(allow_query: query_params.split(":"))
    path = bluri.path
    bluri.query ? (path + '?' + bluri.query) : path
  end
end
