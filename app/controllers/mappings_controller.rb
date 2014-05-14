require 'view/mappings/canonical_filter'

class MappingsController < ApplicationController
  include PaperTrail::Controller
  include BackgroundBulkAddMessageControllerMixin

  before_filter :find_site, except: [:find_global]
  before_filter :check_global_redirect_or_archive, except: [:find_global]
  before_filter :check_user_can_edit, except: [:index, :find, :find_global]
  before_filter :set_background_bulk_add_status_message, except: [:find_global]

  def new_multiple
    paths = params[:paths].present? ? params[:paths].split(',') : []
    @batch = MappingsBatch.new(paths: paths)
  end

  def new_multiple_confirmation
    @batch = MappingsBatch.new(http_status: params[:http_status],
                               new_url: params[:new_url],
                               tag_list: params[:tag_list],
                               paths: params[:paths].split(/\r?\n|\r/).map(&:strip))
    @batch.user = current_user
    @batch.site = @site

    unless @batch.save
      render action: 'new_multiple'
    end
  end

  def create_multiple
    @batch = @site.mappings_batches.find(params[:mappings_batch_id])
    if @batch.state == 'unqueued'
      @batch.update_attributes!(update_existing: params[:update_existing], tag_list: params[:tag_list], state: 'queued')
      if @batch.invalid?
        render action: 'new_multiple_confirmation' and return
      end

      if @batch.entries_to_process.count > 20
        MappingsBatchWorker.perform_async(@batch.id)
        flash[:show_background_bulk_add_progress_modal] = true
      else
        @batch.process
        @batch.update_column(:seen_outcome, true)

        outcome = MappingsBatchOutcomePresenter.new(@batch)
        flash[:saved_mapping_ids] = outcome.affected_mapping_ids
        flash[:success] = outcome.success_message
        flash[:saved_operation] = outcome.operation_description
      end
    end

    if Transition::OffSiteRedirectChecker.on_site?(params[:return_path])
      redirect_to params[:return_path]
    else
      redirect_to site_mappings_path(@site)
    end
  end

  def index

    @mappings = @site.mappings.page(params[:page])

    if params[:type] == 'archive' && params[:new_url_contains].present?
      @incompatible_filter = true
    end

    if params[:type] == 'redirect'
      @filtered = true
      @type = params[:type]
      @mappings = @mappings.redirects
    elsif params[:type] == 'archive' && !@incompatible_filter
      @filtered = true
      @type = params[:type]
      @mappings = @mappings.archives
    end

    if params[:path_contains].present?
      @path_contains = View::Mappings::canonical_filter(@site, params[:path_contains])
      if @path_contains.present?
        @filtered = true

        # Canonicalisation removes trailing slashes, which in this case
        # can be an important part of the search string. Put them back.
        if params[:path_contains].end_with?('/')
          @path_contains = @path_contains + '/'
        end

        @mappings = @mappings.filtered_by_path(@path_contains)
      end
    end

    if params[:new_url_contains].present?
      @filtered = true
      @new_url_contains = params[:new_url_contains]
      @mappings = @mappings.redirects.filtered_by_new_url(@new_url_contains)
    end

    if params[:tagged].present?
      @filtered = true
      @mappings = @mappings.tagged_with(params[:tagged])
    end

    if params[:sort] == 'by_hits'
      @filtered = true
      @sorted_by_hits = true
      @mappings = @mappings.with_hit_count.order('hit_count DESC')
    else
      @mappings = @mappings.order(:path)
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
      flash[:saved_mapping_ids] = [@mapping.id]
      flash[:saved_operation] = "update-single"

      if Transition::OffSiteRedirectChecker.on_site?(params[:return_path])
        redirect_to params[:return_path]
      else
        redirect_to site_mappings_path(@site)
      end
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
      flash[:saved_mapping_ids] = bulk_edit.mappings.map {|m| m.id}
      flash[:saved_operation] = bulk_edit.operation_description
      redirect_to bulk_edit.return_path
    end
  end

  def find_global
    # This allows finding a mapping without knowing the site first.
    render_error(400) and return unless params[:url].present?

    begin
      url = URI.parse(params[:url])
      render_error(400) and
        return unless url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      render_error(400) and return
    end

    url.host = Host.canonical_hostname(url.host)
    site = Host.where(hostname: url.host).first.try(:site)
    unless site
      render_error(404,
          header: 'Unknown site',
          body:  "#{url.host} isn't configured in Transition yet. To add this site to Transition, please contact your Transition Manager")
      return
    end

    redirect_to site_mapping_find_url(site, path: url.request_uri)
  end

  def find
    path = @site.canonical_path(params[:path])

    if path.empty?
      notice = t('mappings.not_possible_to_edit_homepage_mapping')
      return redirect_to back_or_mappings_index, notice: notice
    end

    mapping = @site.mappings.find_by_path(path)
    if mapping.present?
      redirect_to edit_site_mapping_path(@site, mapping, return_path: params[:return_path])
    else
      redirect_to new_multiple_site_mappings_path(@site, paths: path, return_path: params[:return_path])
    end
  end

private
  def bulk_edit
    @bulk_edit ||= bulk_editor_class.new(@site, params, site_mappings_path(@site))
  end

  def bulk_editor_class
    params[:operation] == 'tag' ? View::Mappings::BulkTagger : View::Mappings::BulkEditor
  end

  def find_site
    @site = Site.find_by_abbr!(params[:site_id])
  end

  def check_user_can_edit
    unless current_user.can_edit_site?(@site)
      message = "You don't have permission to edit mappings for #{@site.default_host.hostname}"
      redirect_to site_mappings_path(@site), alert: message
    end
  end

  def back_or_mappings_index
    referer = request.env['HTTP_REFERER']
    if referer && URI.parse(referer).host == request.host
      referer
    else
      site_mappings_path(@site)
    end
  end

  def check_global_redirect_or_archive
    if @site.global_http_status.present?
      if @site.global_http_status == '301'
        message = "This site has been entirely redirected."
      elsif @site.global_http_status == '410'
        message = "This site has been entirely archived."
      end
      redirect_to site_path(@site), alert: "#{message} You can't edit its mappings."
    end
  end
end
