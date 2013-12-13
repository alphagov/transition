class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth

  def admin?
    permissions.include?('admin')
  end

  def can_edit?(organisation_to_edit)
    admin? ||
      organisation == organisation_to_edit ||
      organisation_to_edit.parent_organisations.include?(organisation)
  end

  def can_edit_site?(site)
    (site.managed_by_transition == true) && can_edit?(site.organisation)
  end

  def organisation
    @_organisation ||=
      Organisation.find_by_whitehall_slug(organisation_slug) if organisation_slug
  end

  def is_human?
    ! is_robot?
  end
end
