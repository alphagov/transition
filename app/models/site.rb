class Site < ActiveRecord::Base
  belongs_to :organisation

  has_many :hosts
  has_many :mappings
  has_many :hits, through: :hosts
  has_many :daily_hit_totals, through: :hosts

  validates_presence_of :abbr
  validates_uniqueness_of :abbr

  def to_param
    abbr
  end

  def default_host
    hosts.first
  end

  def canonical_path_from_url(raw_url)
    bluri = BLURI(raw_url).canonicalize!(allow_query: query_params.split(":"))
    path = bluri.path
    bluri.query ? (path + '?' + bluri.query) : path
  end

  def canonicalize_path(raw_path)
    # BLURI takes a full URL, but we only care about the path. There's no
    # benefit in making an extra query to get a real hostname for the site.
    raw_url = 'http://www.example.com' + raw_path
    canonical_path_from_url(raw_url)
  end
end
