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
    store_site_return_url

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
    set_vars_from_params_for_edit_multiple
    error = mappings_or_status_error
    return error if error

    if request.xhr?
      render 'edit_multiple_modal', layout: nil
    end
  end

  def update_multiple
    set_vars_from_params_for_edit_multiple
    error = mappings_or_status_error
    return error if error

    @update_data = { http_status: @http_status }
    if @http_status == '301'
      @update_data[:new_url] = @new_url = params[:new_url]
    end

    # Before trying to update any real mappings, construct a test mapping using
    # the submitted data to see if it validates:
    test_data = { site: @site, path: '/this/is/a/test/and/will/not/be/saved' }.merge(@update_data)
    test_mapping = Mapping.new(test_data)
    unless test_mapping.valid?
      if test_mapping.errors.size == 1 && test_mapping.errors[:new_url].present?
        # Assume that new_url was blank or invalid:
        @new_url_error = 'Enter a valid URL to redirect these paths to'
        render action: 'edit_multiple' and return
      else
        # Something else wasn't valid and the user can't do anything about it now:
        return redirect_to site_return_url, notice: 'Validation failed'
      end
    end

    failed_update_ids = bulk_update_mappings.compact
    if failed_update_ids.present?
      @mappings = @site.mappings.where(id: failed_update_ids).order(:path)
      flash[:notice] = 'The following mappings could not be updated'
      render action: 'edit_multiple'
    else
      redirect_to site_return_url, notice: 'Mappings updated successfully'
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

  def site_return_url_key
    "return_to_#{@site.abbr}".to_sym
  end

  def store_site_return_url
    session[site_return_url_key] = request.url
  end

  def site_return_url
    session[site_return_url_key] || site_mappings_path(@site)
  end

  def set_vars_from_params_for_edit_multiple
    @mappings = @site.mappings.where(id: params[:mapping_ids]).order(:path)
    @http_status = params[:http_status] if ['301', '410'].include?(params[:http_status])
    @back_to_index = site_return_url
  end

  def mappings_or_status_error
    case
    when @mappings.empty?
      redirect_to site_return_url, notice: 'No mappings were selected'
    when @http_status.blank?
      redirect_to site_return_url, notice: 'Please select either redirect or archive'
    end
  end

  def bulk_update_mappings
    @mappings.map do |m|
      # update_attributes validates before saving
      m.update_attributes(@update_data) ? nil : m.id
    end
  end
end
