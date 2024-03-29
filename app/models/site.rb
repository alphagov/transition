require "./lib/transition/path_or_url"

class Site < ApplicationRecord
  include NilifyBlanks

  GLOBAL_TYPES = { redirect: "redirect", archive: "archive" }.freeze
  SPECIAL_REDIRECT_STRATEGY_TYPES = { via_aka: "via_aka", supplier: "supplier" }.freeze

  has_paper_trail

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
                          join_table: "organisations_sites",
                          class_name: "Organisation"

  validates :tna_timestamp, presence: true
  validates :organisation, presence: true
  validates :homepage, presence: true, non_blank_url: { message: :non_blank_url }
  validates :special_redirect_strategy, inclusion: { in: SPECIAL_REDIRECT_STRATEGY_TYPES.values, allow_blank: true }
  validates :global_new_url, presence: { if: :global_redirect? }
  validates :global_new_url, absence: { if: :global_archive? }
  validates :global_new_url,
            format: { without: /\?/,
                      message: :has_query,
                      if: :global_redirect_append_path }

  after_update :update_hits_relations, if: :saved_change_to_query_params?
  after_update :remove_all_hits_view,  if: :should_remove_unused_view?

  scope :with_mapping_count,
        lambda {
          select("sites.*, COUNT(mappings.id) as mapping_count")
            .joins("LEFT JOIN mappings on mappings.site_id = sites.id")
            .group("sites.id")
        }

  def mapping_count
    self[:mapping_count].to_i
  end

  def global_redirect?
    global_type == "redirect"
  end

  def global_archive?
    global_type == "archive"
  end

  def default_host
    @default_host ||= hosts.excluding_aka.order(:id).first
  end

  def hosts_excluding_primary_and_aka
    hosts.excluding(default_host).excluding_aka
  end

  def transition_status
    return :live          if hosts.excluding_aka.any?(&:redirected_by_gds?)
    return :indeterminate if special_redirect_strategy.present?

    :pre_transition
  end

  def canonical_path(path_or_url)
    url = if ::Transition::PathOrURL.starts_with_http_scheme?(path_or_url)
            path_or_url
          elsif !path_or_url.starts_with?("/") &&
              ::Transition::PathOrURL.starts_with_a_domain?(path_or_url)
            "http://#{path_or_url}"
          else
            # BLURI takes a full URL, but we only care about the path. There's no
            # benefit in making an extra query to get a real hostname for the site.
            File.join("http://www.example.com", path_or_url)
          end

    bluri = BLURI(url).canonicalize!(allow_query: query_params.split(":"))
    path = bluri.path
    bluri.query ? "#{path}?#{bluri.query}" : path
  end

  def hit_total_count
    @hit_total_count ||= daily_hit_totals.sum(:count)
  end

  def update_hits_relations
    host_paths.update_all(mapping_id: nil, canonical_path: nil)
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
      .select("tags.name, COUNT(*) AS count")
      .joins(:taggings)
      .joins("INNER JOIN mappings ON mappings.id = taggings.taggable_id")
      .where("mappings.site_id = ?", id)
      .group("tags.name")
      .order("count DESC, tags.name")
      .limit(limit)
      .map(&:name)
  end

  def precomputed_all_hits
    Hit.select("*").from(ActiveRecord::Base.connection.quote_table_name(precomputed_view_name))
  end

  def precomputed_view_name
    @_precomputed_view_name = %(all_hits_#{id})
  end

  def able_to_use_view?
    precompute_all_hits_view && Postgres::MaterializedView.exists?(precomputed_view_name)
  end

  def self.find_by_abbr_or_id(abbr_or_id)
    find_by(abbr: abbr_or_id) || find(abbr_or_id)
  end

private

  def should_remove_unused_view?
    saved_change_to_precompute_all_hits_view? && precompute_all_hits_view == false
  end

  def remove_all_hits_view
    Postgres::MaterializedView.drop(precomputed_view_name)
  end

  def nilify_except
    %i[global_redirect_append_path query_params precompute_all_hits_view]
  end
end
