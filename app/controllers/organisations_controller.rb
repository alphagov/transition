class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.with_sites_managed_by_transition.order(:title)
    @site_count = Site.managed_by_transition.count
  end

  def show
    @organisation = Organisation.find_by_whitehall_slug!(organisation_params[:id])
    sites = @organisation.sites.managed_by_transition.includes(:hosts)
    extra_sites = @organisation.extra_sites.managed_by_transition.includes(:hosts)
    @sites = sites.concat(extra_sites).sort_by!(&:abbr)
  end

  private
  def organisation_params
    params.permit(:id, :title, :homepage, :furl, :css)
  end
end
