class MappingsController < ApplicationController
  include PaperTrail::Controller

  before_filter :find_site
  before_filter :check_user_can_edit, except: [:index, :find]

  def new_multiple
    bulk_add
  end

  def new_multiple_confirmation
    if bulk_add.params_invalid?
      @errors = bulk_add.params_errors
      render action: 'new_multiple'
    end
  end

  def create_multiple
    if bulk_add.params_invalid?
      @errors = bulk_add.params_errors
      render action: 'new_multiple' and return
    end

    bulk_add.create_or_update!

    flash[:success] = bulk_add.success_message
    redirect_to site_return_path
  end

  def index
    store_site_return_path

    @path_contains = begin
      params[:contains] =~ %r{^https?://} ? URI.parse(params[:contains]).path :
                                            params[:contains]
    rescue URI::InvalidURIError
      params[:contains]
    end

    @mappings = @site.mappings.order(:path).page(params[:page])
    @mappings = if params[:filter_field] == 'new_url'
       @mappings.redirects.filtered_by_new_url(@path_contains)
    else
       @mappings.filtered_by_path(@path_contains)
    end
  end

  def edit
    @mapping = Mapping.find(params[:id])
  end

  def update
    @mapping = @site.mappings.find(params[:id])
    if @mapping.update_attributes(params[:mapping])
      flash[:success] = 'Mapping saved'
      redirect_to edit_site_mapping_path(@site, @mapping)
    else
      render action: 'edit'
    end
  end

  def edit_multiple
    redirect_to site_return_path, notice: bulk_edit.params_errors and return if bulk_edit.params_invalid?

    if request.xhr?
      render 'edit_multiple_modal', layout: nil
    end
  end

  def update_multiple
    redirect_to site_return_path, notice: bulk_edit.params_errors and return if bulk_edit.params_invalid?

    if bulk_edit.would_fail?
      if bulk_edit.would_fail_on_new_url?
        @new_url_error = t('mappings.bulk.new_url_invalid')
        render action: 'edit_multiple' and return
      else
        flash[:danger] = 'Validation failed'
        return redirect_to site_return_path
      end
    end

    bulk_edit.update!

    if bulk_edit.failures?
      @mappings = bulk_edit.failures
      flash[:notice] = 'The following mappings could not be updated'
      render action: 'edit_multiple'
    else
      flash[:success] = 'Mappings updated successfully'
      redirect_to site_return_path
    end
  end

  def find
    path = @site.canonical_path(params[:path])

    if path.empty?
      notice = t('mappings.not_possible_to_edit_homepage_mapping')
      return redirect_to back_or_mappings_index, notice: notice
    end

    mapping = @site.mappings.find_by_path(path)
    if mapping.present?
      redirect_to edit_site_mapping_path(@site, mapping)
    else
      redirect_to new_multiple_site_mappings_path(@site, paths: path)
    end
  end

private
  def bulk_add
    @bulk_add ||= View::Mappings::BulkAdder.new(@site, params, site_return_path)
  end

  def bulk_edit
    @bulk_edit ||= View::Mappings::BulkEditor.new(@site, params, site_return_path)
  end

  def find_site
    @site = Site.find_by_abbr(params[:site_id])
  end

  def check_user_can_edit
    unless current_user.can_edit?(@site.organisation)
      message = "You don't have permission to edit site mappings for #{@site.organisation.title}"
      redirect_to site_mappings_path(@site), alert: message
    end
  end

  def back_or_mappings_index
    request.env['HTTP_REFERER'] || site_mappings_path(@site)
  end

  def site_return_path_key
    "return_to_#{@site.abbr}".to_sym
  end

  def store_site_return_path
    session[site_return_path_key] = request.fullpath
  end

  def site_return_path
    session[site_return_path_key] || site_mappings_path(@site)
  end
end
