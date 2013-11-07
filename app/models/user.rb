class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth

  def admin?
    permissions.include?("admin")
  end

  def can_edit?(organisation_to_edit)
    case
    when admin?
      true
    when organisation.nil?
      false
    when organisation.id == organisation_to_edit.id
      true
    when organisation.id == organisation_to_edit.parent_id
      true
    else
      false
    end
  end

  def organisation
    @_organisation ||= begin
      if self.organisation_slug
        Organisation.find_by_whitehall_slug(self.organisation_slug)
      else
        nil
      end
    end
  end
end
