class SetOrganisationalRelationships < ActiveRecord::Migration
  class OrganisationalRelationship < ApplicationRecord
    belongs_to :parent_organisation, class_name: "Organisation"
    belongs_to :child_organisation, class_name: "Organisation"
  end

  class Organisation < ApplicationRecord
    belongs_to :parent, class_name: Organisation, foreign_key: "parent_id"

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
  end

  def up
    Organisation.all.each do |org|
      if org.parent.present?
        org.parent_organisations << org.parent
      end
    end
  end

  def down
    Organisation.all.each do |org|
      if org.parent_organisations.present?
        org.parent = org.parent_organisations.first
        org.save
      end
    end
  end
end
