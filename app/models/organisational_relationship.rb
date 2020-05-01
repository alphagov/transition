class OrganisationalRelationship < ApplicationRecord
  belongs_to :parent_organisation, class_name: "Organisation"
  belongs_to :child_organisation, class_name: "Organisation"
  validate :org_cannot_be_its_own_parent

  def org_cannot_be_its_own_parent
    if parent_organisation_id == child_organisation_id
      errors[:base] << "An organisation cannot be its own parent."
    end
  end
end
