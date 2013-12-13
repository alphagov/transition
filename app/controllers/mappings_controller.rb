class MappingsController < ApplicationController
  include PaperTrail::Controller

  before_filter do
    @site = Site.find_by_abbr(params[:site_id])
  end

  before_filter :check_user_can_edit, only: [:new, :create, :edit, :update, :edit_multiple, :update_multiple]

  def new
    @mapping = @site.mappings.build(path: params[:path])
  end

  def create
    @mapping = @site.mappings.build(params[:mapping])
    if @mapping.save
      redirect_to edit_site_mapping_path(@site, @mapping), notice: view_context.created_mapping(@mapping)
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
      redirect_to edit_site_mapping_path(@site, @mapping), notice: 'Mapping saved.'
    else
      render action: 'edit'
    end
  end

  def edit_multiple
    @mappings = @site.mappings.where(id: params[:mapping_ids]).order(:path)
    @http_status = params[:http_status] if ['301', '410'].include?(params[:http_status])
    unless @mappings.present?
      return redirect_to back_or_mappings_index, notice: 'No mappings were selected'
    end
    unless @http_status.present?
      return redirect_to back_or_mappings_index, notice: 'Please select either redirect or archive'
    end
    if request.xhr?
      render 'edit_multiple_modal', layout: nil
    end
  end

  def update_multiple
    @http_status = params[:http_status] if ['301', '410'].include?(params[:http_status])
    @update_data = { http_status: @http_status }
    if @http_status == '301'
      @new_url = params[:new_url]
      @update_data[:new_url] = @new_url
    end

    # Before trying to update any real mappings, construct a test mapping using
    # the submitted data to see if it validates:
    test_data = { site: @site, path: '/this/is/a/test/and/will/not/be/saved' }.merge(@update_data)
    test_mapping = Mapping.new(test_data)
    unless test_mapping.valid?
      # test_mapping.errors now contains useful things which we could display
      return redirect_to site_mappings_path(@site), notice: 'Validation failed'
    end

    @mappings = @site.mappings.where(id: params[:mapping_ids]).order(:path)

    unless @mappings.present?
      return redirect_to back_or_mappings_index, notice: 'No mappings were selected'
    end

    if bulk_update_mappings.all?
      # FIXME: redirect back to index, preserving path filter and pagination
      redirect_to site_mappings_path(@site), notice: 'Mappings updated'
    else
      # FIXME: doesn't display notice or invalid URL error message
      render action: 'edit_multiple', notice: 'Mappings could not be updated'
    end
  end

  def find
    path = @site.canonicalize_path(params[:path])

    if path.empty?
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

  def back_or_mappings_index
    request.env['HTTP_REFERER'] || site_mappings_path(@site)
  end

  def bulk_update_mappings
    # FIXME: should we remove suggested and archive urls if http_status is
    # redirect, and new_url if http_status is archive?
    @mappings.map do |m|
      m.update_attributes(@update_data)
    end
  end
end
