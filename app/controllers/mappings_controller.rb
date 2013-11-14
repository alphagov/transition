class MappingsController < ApplicationController
  include PaperTrail::Controller

  before_filter do
    @site = Site.find_by_abbr(params[:site_id])
  end

  before_filter :check_user_can_edit, only: [:new, :create, :edit, :update]

  def new
    @mapping = @site.mappings.build(path: params[:path])
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

  def find
    path = @site.canonicalize_path(params[:path])

    if path.empty?
      back_or_mappings_index = request.env['HTTP_REFERER'] || site_mappings_path(@site)
      notice = t('not_possible_to_edit_homepage_mapping')
      return redirect_to back_or_mappings_index, notice: notice
    end

    mapping = @site.mappings.find_by_path(path)
    if mapping.present?
      redirect_to edit_site_mapping_path(@site, mapping)
    else
      redirect_to new_site_mapping_path(@site, path: path)
    end
  end

private
  def check_user_can_edit
    unless current_user.can_edit?(@site.organisation)
      message = "You don't have permission to edit site mappings for #{@site.organisation.title}"
      redirect_to site_mappings_path(@site), alert: message
    end
  end
end
