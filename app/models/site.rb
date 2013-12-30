class Site < ActiveRecord::Base
  belongs_to :organisation

  has_many :hosts
  has_many :mappings
  has_many :hits, through: :hosts
  has_many :daily_hit_totals, through: :hosts

  validates_presence_of :abbr
  validates_presence_of :tna_timestamp
  validates_presence_of :organisation
  validates_uniqueness_of :abbr

  scope :managed_by_transition, where(managed_by_transition: true)

  def to_param
    abbr
  end

  def default_host
    hosts.first
  end

  def canonical_path(path_or_url)
    if path_or_url.start_with?('http')
      url = path_or_url
    else
      # BLURI takes a full URL, but we only care about the path. There's no
      # benefit in making an extra query to get a real hostname for the site.
      url = 'http://www.example.com' + path_or_url
    end

    bluri = BLURI(url).canonicalize!(allow_query: query_params.split(":"))
    path = bluri.path
    bluri.query ? (path + '?' + bluri.query) : path
  end

  def transition_state
    (hosts.map { |h| h.redirected_by_gds? }).any? ? 'live' : 'pre-transition'
  end
end
