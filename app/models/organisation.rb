class Organisation < ActiveRecord::Base

  belongs_to :parent, class_name: Organisation, foreign_key: 'parent_id'

  has_many :child_organisational_relationships,
            foreign_key: :parent_organisation_id,
            class_name: "OrganisationalRelationship"
  has_many :parent_organisational_relationships,
            foreign_key: :child_organisation_id,
            class_name: "OrganisationalRelationship",
            dependent: :destroy
  has_many :child_organisations,
            through: :child_organisational_relationships
  has_many :parent_organisations,
            through: :parent_organisational_relationships

  has_and_belongs_to_many :extra_sites,
                           join_table: 'organisations_sites',
                           class_name: 'Site'

  has_many :sites
  has_many :hosts, through: :sites
  has_many :mappings, through: :sites

  validates_presence_of :whitehall_slug
  validates_uniqueness_of :whitehall_slug
  validates_presence_of :title

  # We have two ways of joining a site to an org:
  # 1. By the site's FK relationship to organisations
  # 2. Through the many-to-many organisations_sites
  #
  # UNION these two ways in an INNER JOIN to pretend that the FK relationship
  # is in fact a row in organisations_sites.
  def self.with_sites_managed_by_transition
    raise RuntimeError, "Postgres TODO 6: #{self}.#{__method__} - \n\t" \
      'Digit boolean and sloppy GROUP BY'
    # See commented-out scope below
  end
  # scope :with_sites_managed_by_transition,
  #       select('organisations.*, count(sites.id) AS site_count').
  #       joins(
  #          'INNER JOIN (
  #       	    SELECT organisation_id, site_id FROM organisations_sites
  #       		  UNION
  #       		  SELECT s.organisation_id, s.id FROM sites s
  #       	) AS organisations_sites ON organisations_sites.organisation_id = organisations.id').
  #       joins('INNER JOIN sites ON sites.id = organisations_sites.site_id').
  #       where('sites.managed_by_transition = 1').
  #       group('organisations.id').  # Using a sloppy mySQL GROUP. Note well, Postgres upgraders
  #       having('site_count > 0')

  # Returns organisations ordered by descending error count across
  # all their sites.
  scope :leaderboard, -> { select(<<-mySQL
    organisations.title,
    organisations.whitehall_slug,
    COUNT(*)                                     AS site_count,
    SUM(site_mapping_counts.mapping_count)       AS mappings_across_sites,
    SUM(unresolved_mapping_counts.mapping_count) AS unresolved_mapping_count,
    SUM(error_counts.error_count)                AS error_count
  mySQL
  ).joins(<<-mySQL
    INNER JOIN sites
           ON sites.`organisation_id` = organisations.id
    LEFT JOIN (SELECT sites.id AS site_id,
                      COUNT(*) AS mapping_count
               FROM   mappings
                      INNER JOIN sites
                              ON sites.id = mappings.site_id
               GROUP  BY sites.id) site_mapping_counts ON site_mapping_counts.site_id = sites.id
    LEFT JOIN (SELECT sites.id AS site_id,
                      COUNT(*) AS mapping_count
               FROM   mappings
                      INNER JOIN sites
                              ON sites.id = mappings.site_id
               WHERE  mappings.type = 'unresolved'
               GROUP  BY sites.id) unresolved_mapping_counts ON unresolved_mapping_counts.site_id = sites.id
    LEFT JOIN (SELECT hosts.site_id AS site_id,
                      SUM(count) AS error_count
               FROM   daily_hit_totals
                      INNER JOIN `hosts`
                              ON `hosts`.id = daily_hit_totals.host_id
               WHERE  daily_hit_totals.http_status = '404'
               AND daily_hit_totals.total_on >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
               GROUP BY site_id) AS error_counts ON error_counts.site_id = sites.id
    mySQL
  ).group('organisations.id').order('error_count DESC') }

  def to_param
    whitehall_slug
  end
end
