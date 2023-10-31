class User < ApplicationRecord
  include GDS::SSO::User

  has_many :mappings_batches
  has_many :bulk_add_batches
  has_many :import_batches

  serialize :permissions, type: Array

  def admin?
    permissions.include?("admin")
  end

  def gds_editor?
    permissions.include?("GDS Editor")
  end

  def site_manager?
    permissions.include?("Site Manager")
  end

  def can_edit_sites
    @can_edit_sites ||= {}
  end

  def can_edit_site?(site_to_edit)
    can_edit_sites[site_to_edit.abbr] ||= site_is_editable?(site_to_edit) && has_permission_to_edit_site?(site_to_edit)
  end

  def own_organisation
    if organisation_content_id
      @_own_organisation ||=
        Organisation.find_by(content_id: organisation_content_id)
    end
  end

private

  def site_is_editable?(site_to_edit)
    site_to_edit.global_type.blank?
  end

  def has_permission_to_edit_site?(site_to_edit)
    gds_editor? ||
      (own_organisation == site_to_edit.organisation) ||
      site_to_edit.organisation.parent_organisations.include?(own_organisation) ||
      site_to_edit.extra_organisations.include?(own_organisation)
  end
end
