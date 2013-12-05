class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.order(:title)
    @site_count = Site.count
  end

  def show
    @organisation = Organisation.find_by_whitehall_slug(params[:id])
    @sites = @organisation.sites.order(:abbr)
  end
end
