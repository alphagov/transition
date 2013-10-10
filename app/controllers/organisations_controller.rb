class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.order(:title)
  end

  def show
    @organisation = Organisation.find_by_abbr(params[:id])
  end
end
