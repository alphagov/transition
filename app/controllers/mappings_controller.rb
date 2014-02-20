require 'view/mappings/canonical_filter'

class MappingsController < ApplicationController
  include PaperTrail::Controller

  before_filter :find_site, except: [:find_global]
  before_filter :check_user_can_edit, except: [:index, :find, :find_global]

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
    redirect_to site_mappings_path(@site)
  end

  def index
    @path_contains =
      if (params[:filter_field] == 'new_url')
        params[:contains]
      else
        View::Mappings::canonical_filter(@site, params[:contains])
      end

    @mappings = @site.mappings.order(:path).page(params[:page])
    @mappings = if params[:filter_field] == 'new_url'
      @mappings.redirects.filtered_by_new_url(@path_contains)
    else
      @mappings.filtered_by_path(@path_contains)
    end

    if params[:tagged].present?
      @mappings = @mappings.tagged_with(params[:tagged])
    end
  end

  def edit
    @mapping = Mapping.find(params[:id])
  end

  def update
    @mapping = @site.mappings.find(params[:id])

    # Tags must be assigned to separately
    @mapping.tag_list = params[:mapping].delete(:tag_list)
    @mapping.attributes = params[:mapping]

    if @mapping.save
      flash[:success] = 'Mapping saved'
      redirect_to edit_site_mapping_path(@site, @mapping)
    else
      render action: 'edit'
    end
  end

  def edit_multiple
    redirect_to bulk_edit.return_path, notice: bulk_edit.params_errors and return if bulk_edit.params_invalid?

    if request.xhr?
      render 'edit_multiple_modal', layout: nil
    end
  end

  def update_multiple
    redirect_to bulk_edit.return_path, notice: bulk_edit.params_errors and return if bulk_edit.params_invalid?

    if bulk_edit.would_fail?
      if bulk_edit.would_fail_on_new_url?
        @new_url_error = t('mappings.bulk.new_url_invalid')
        render action: 'edit_multiple' and return
      else
        flash[:danger] = 'Validation failed'
        return redirect_to bulk_edit.return_path
      end
    end

    bulk_edit.update!

    if bulk_edit.failures?
      @mappings = bulk_edit.failures
      flash[:notice] = 'The following mappings could not be updated'
      render action: 'edit_multiple'
    else
      flash[:success] = bulk_edit.success_message
      redirect_to bulk_edit.return_path
    end
  end

  def find_global
    # This allows finding a mapping without knowing the site first.
    render status: 404, text: "aka_url not present" and
      return unless params[:aka_url].present?

    uri = URI.parse(params[:aka_url])
    render status: 400, text: "aka_url not an HTTP or HTTPS URI" and
      return unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    # Perform Bouncer's AKA matching to switch aka to www as per the
    # comment in Host#aka_hostname.
    uri.host = uri.host.sub(/^aka-/, '').sub(/^aka\./, 'www.')
    site = Host.where(hostname: "#{uri.host}").first.try(:site)
    render status: 404, text: "#{uri.host} not found" and
      return unless site

    redirect_to site_mapping_find_url(site, path: uri.path)
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
    @bulk_add ||= View::Mappings::BulkAdder.new(@site, params)
  end

  def bulk_edit
    @bulk_edit ||= bulk_editor_class.new(@site, params, site_mappings_path(@site))
  end

  def bulk_editor_class
    params[:operation] == 'tag' ? View::Mappings::BulkTagger : View::Mappings::BulkEditor
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
end
