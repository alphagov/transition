class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.with_sites.order(:title)
    @site_count = Site.count
  end

  def show
    @organisation = Organisation.find_by_whitehall_slug(params[:id])
    @sites_managed_by_transition = @organisation.sites.managed_by_transition.order(:abbr)
    @sites_not_managed_by_transition = @organisation.sites.not_managed_by_transition.order(:abbr)
  end
end
