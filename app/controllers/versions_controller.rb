class VersionsController < ApplicationController
  def index
    @mapping = Mapping.find(params[:mapping_id])
    @versions = @mapping.versions
  end
end
