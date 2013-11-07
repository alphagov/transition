class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth

  def gds_transition_manager?
    permissions.include?("GDS Transition Manager")
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
