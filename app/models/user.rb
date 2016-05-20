class User < ActiveRecord::Base

  has_many :mappings_batches
  has_many :bulk_add_batches
  has_many :import_batches

  serialize :permissions, Array

  def admin?
    permissions.include?('admin')
  end

  def gds_editor?
    permissions.include?('GDS Editor')
  end

  def can_edit_sites
    @can_edit_sites ||= {}
  end

  def can_edit_site?(site_to_edit)
    can_edit_sites[site_to_edit.abbr] ||= begin
      gds_editor? ||
        own_organisation == site_to_edit.organisation ||
        site_to_edit.organisation.parent_organisations.include?(own_organisation) ||
        site_to_edit.extra_organisations.include?(own_organisation) &&
        site_to_edit.global_type.blank?
    end
  end

  def own_organisation
    @_own_organisation ||=
      Organisation.find_by_content_id(organisation_content_id) if organisation_content_id
  end

  def is_human?
    ! is_robot?
  end
end
