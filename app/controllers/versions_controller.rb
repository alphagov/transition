class VersionsController < ApplicationController
  tracks_mappings_progress

  def index
    @mapping = Mapping.find(version_params[:mapping_id])
    @versions = @mapping.versions
  end

  private
  def version_params
    params.permit(:user_id, :mapping_id)
  end
end
