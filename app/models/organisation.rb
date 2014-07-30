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
  scope :with_sites_managed_by_transition,
        select('organisations.*, COUNT(*) as site_count').
        joins(
           'INNER JOIN (
        	    SELECT organisation_id, site_id FROM organisations_sites
        		  UNION
        		  SELECT s.organisation_id, s.id FROM sites s
        	) AS organisations_sites ON organisations_sites.organisation_id = organisations.id').
        joins('INNER JOIN sites ON sites.id = organisations_sites.site_id').
        where('sites.managed_by_transition = TRUE').
        group('organisations.id'). # Postgres will accept a group by primary key
        having('COUNT(*) > 0')

  def to_param
    whitehall_slug
  end
end
