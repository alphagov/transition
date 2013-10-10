class MappingsController < ApplicationController
  include PaperTrail::Controller

  before_filter do
    @site = Site.find_by_abbr(params[:site_id])
  end

  def new
    @mapping = @site.mappings.build
  end

  def create
    @mapping = @site.mappings.build(params[:mapping])
    if @mapping.save
      redirect_to site_mappings_path(@site), notice: 'Mapping saved.'
    else
      render action: 'new'
    end
  end

  def index
    @mappings = @site.mappings.filtered_by_path(params[:contains]).order(:path).page(params[:page])
  end

  def edit
    @mapping = Mapping.find(params[:id])
  end

  def update
    @mapping = @site.mappings.find(params[:id])
    if @mapping.update_attributes(params[:mapping])
      redirect_to site_mappings_path(@site), notice: 'Mapping saved.'
    else
      render action: 'edit'
    end
  end
end
