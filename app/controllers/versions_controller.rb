class VersionsController < ApplicationController
  tracks_mappings_progress

  def index
    @mapping = Mapping.find(params[:mapping_id])
    @versions = @mapping.versions
  end
end
