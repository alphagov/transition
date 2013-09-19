class MappingsController < ApplicationController
  include PaperTrail::Controller

  def index
    @site = Site.find_by_abbr(params[:site_id])
    @mappings = @site.mappings.filtered_by_path(params[:contains]).page(params[:page])
  end

  def edit
    @site = Site.find_by_abbr(params[:site_id])
    @mapping = Mapping.find(params[:id])
  end

  def update
    @site = Site.find_by_abbr(params[:site_id])
    @mapping = @site.mappings.find(params[:id])
    if @mapping.update_attributes(params[:mapping])
      redirect_to site_mappings_path(@site), notice: 'Mapping saved.'
    else
      render action: 'edit'
    end
  end
end
