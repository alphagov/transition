class Organisation < ActiveRecord::Base
  attr_accessible :title, :homepage, :furl, :css

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

  has_many :sites
  has_many :hosts, through: :sites
  has_many :mappings, through: :sites

  validates_presence_of :whitehall_slug
  validates_uniqueness_of :whitehall_slug
  validates_presence_of :title

  scope :with_sites_managed_by_transition,
        select('organisations.*, count(sites.id) AS site_count').
        joins(:sites).
        where("sites.managed_by_transition = 1").
        group('organisations.id').  # Using a sloppy mySQL GROUP. Note well, Postgres upgraders
        having('site_count > 0')

  def to_param
    whitehall_slug
  end
end
