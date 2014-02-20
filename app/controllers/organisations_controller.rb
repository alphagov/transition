class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.with_sites_managed_by_transition.order(:title)
    @site_count = Site.managed_by_transition.count
  end

  def show
    @organisation = Organisation.find_by_whitehall_slug!(params[:id])
    @sites = @organisation.sites.managed_by_transition.with_mapping_count.
               includes(:hosts).order(:abbr)
  end
end
