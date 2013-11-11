class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth

  def admin?
    permissions.include?("admin")
  end

  def can_edit?(organisation_to_edit)
    admin? ||
      organisation == organisation_to_edit ||
      organisation_to_edit.parent && (organisation == organisation_to_edit.parent)
  end

  def organisation
    @_organisation ||= begin
      if organisation_slug
        Organisation.find_by_whitehall_slug(organisation_slug)
      else
        nil
      end
    end
  end
end
