class Site < ActiveRecord::Base
  belongs_to :organisation

  has_many :hosts
  has_many :mappings
  has_many :hits, through: :hosts
  has_many :daily_hit_totals, through: :hosts
  has_many :host_paths, through: :hosts
  has_many :mappings_batches
  has_and_belongs_to_many :extra_organisations,
                           join_table: 'organisations_sites',
                           class_name: 'Organisation'

  validates_presence_of :abbr
  validates_presence_of :tna_timestamp
  validates_presence_of :organisation
  validates_uniqueness_of :abbr
  validates_inclusion_of :special_redirect_strategy, in: %w{ via_aka supplier }, allow_nil: true

  scope :managed_by_transition, where(managed_by_transition: true)
  scope :with_mapping_count,
        select('sites.*, COUNT(mappings.id) as mapping_count').
          joins('LEFT JOIN mappings on mappings.site_id = sites.id').
          group('sites.id')

  def to_param
    abbr
  end

  def default_host
    hosts.excluding_aka.first
  end

  def transition_status
    return :live          if hosts.excluding_aka.any?(&:redirected_by_gds?)
    return :indeterminate if special_redirect_strategy.present?
           :pre_transition
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

  def hit_total_count
    @hit_total_count ||= daily_hit_totals.pluck(:count).inject(0) { |total, count| total += count }
  end
end
