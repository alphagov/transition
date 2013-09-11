class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all
  end
end
