class Site < ActiveRecord::Base

  belongs_to :organisation

  has_many :hosts
  has_many :mappings
  has_many :hits, through: :hosts
  has_many :daily_hit_totals, through: :hosts
  has_many :host_paths, through: :hosts
  has_many :mappings_batches
  has_many :bulk_add_batches
  has_many :import_batches
  has_and_belongs_to_many :extra_organisations,
                           join_table: 'organisations_sites',
                           class_name: 'Organisation'

  validates_presence_of :tna_timestamp
  validates_presence_of :organisation
  validates :homepage, presence: true, non_blank_url: true
  validates :abbr, uniqueness: true, presence: true, format: { with: /\A[a-zA-Z0-9_\-]+\z/, message: 'can only contain alphanumeric characters, underscores and dashes' }
  validates_inclusion_of :special_redirect_strategy, in: %w{ via_aka supplier }, allow_nil: true
  validates :global_new_url, presence: { :if => :global_redirect? }
  validates :global_new_url, format: { without: /\?/,
                                       message: 'cannot contain a query when the path is appended',
                                       :if => :global_redirect_append_path }

  after_update :update_hits_relations, :if => :query_params_changed?

  scope :managed_by_transition, -> { where(managed_by_transition: true) }
  scope :with_mapping_count, -> {
        select('sites.*, COUNT(mappings.id) as mapping_count').
          joins('LEFT JOIN mappings on mappings.site_id = sites.id').
          group('sites.id') }

  def to_param
    abbr
  end

  def global_redirect?
    global_type == 'redirect'
  end

  def global_archive?
    global_type == 'archive'
  end

  def default_host
    @default_host ||= hosts.excluding_aka.order(:id).first
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
    @hit_total_count ||= daily_hit_totals.select('SUM(count) AS total').first[:total].to_i
  end

  def update_hits_relations
    host_paths.update_all(mapping_id: nil, c14n_path_hash: nil)
    hits.update_all(mapping_id: nil)
    Transition::Import::HitsMappingsRelations.refresh!(self)
  end

  ##
  # Get the most-used tags for mappings for this site.
  # Returns an array of strings.
  def most_used_tags(limit = 50)
    # Assumes that only Mappings are taggable for a 25-30% speed boost.
    # Remove this assumption by qualifying the mappings join should
    # we need to tag anything else. This replaces ActsAsTaggableOn's
    # generic (but slow) Model.tag_counts_on for our limited use case.
    ActsAsTaggableOn::Tag
      .select('tags.name, COUNT(*) AS count')
      .joins(:taggings)
      .joins('INNER JOIN mappings ON mappings.id = taggings.taggable_id')
      .where('mappings.site_id = ?', id)
      .group('tags.name')
      .order('count DESC')
      .limit(limit)
      .map(&:name)
  end
end
