class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.order(:title)
  end

  def show
    @organisation = Organisation.find_by_redirector_abbr(params[:id])
    @sites = @organisation.sites.order(:abbr)
  end
end
