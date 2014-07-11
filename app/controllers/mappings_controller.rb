require 'view/mappings/canonical_filter'

class MappingsController < ApplicationController
  include PaperTrail::Rails::Controller

  tracks_mappings_progress except: [:find_global]

  before_filter :check_global_redirect_or_archive, except: [:find_global]
  checks_user_can_edit except: [:index, :find, :find_global]

  def new_multiple
    paths = params[:paths].present? ? params[:paths].split(',') : []
    @batch = BulkAddBatch.new(paths: paths)
  end

  def new_multiple_confirmation
    @batch = BulkAddBatch.new(type: mapping_params[:type],
                               new_url: mapping_params[:new_url],
                               tag_list: mapping_params[:tag_list],
                               paths: mapping_params[:paths].split(/\r?\n|\r/).map(&:strip))
    @batch.user = current_user
    @batch.site = @site

    unless @batch.save
      render action: 'new_multiple'
    end
  end

  def create_multiple
    @batch = @site.mappings_batches.find(mapping_params[:mappings_batch_id])
    if @batch.state == 'unqueued'
      @batch.update_attributes!(update_existing: mapping_params[:update_existing], tag_list: mapping_params[:tag_list], state: 'queued')
      if @batch.invalid?
        render action: 'new_multiple_confirmation' and return
      end

      if @batch.entries_to_process.count > 20
        MappingsBatchWorker.perform_async(@batch.id)
        flash[:show_background_batch_progress_modal] = true
      else
        @batch.process
        @batch.update_column(:seen_outcome, true)

        outcome = BatchOutcomePresenter.new(@batch)
        flash[:saved_mapping_ids] = outcome.affected_mapping_ids
        flash[:success] = outcome.success_message
        flash[:saved_operation] = outcome.analytics_event_type
      end
    end

    if Transition::OffSiteRedirectChecker.on_site?(mapping_params[:return_path])
      redirect_to mapping_params[:return_path]
    else
      redirect_to site_mappings_path(@site)
    end
  end

  def index
    @filter = View::Mappings::Filter.new(@site, mapping_params)
    @mappings = @filter.mappings
  end

  def edit
    @mapping = Mapping.find(mapping_params[:id])
  end

  def update
    @mapping = @site.mappings.find(mapping_params[:id])

    # Tags must be assigned to separately
    @mapping.tag_list = mapping_params[:mapping].delete(:tag_list)
    @mapping.attributes = mapping_params[:mapping]

    if @mapping.save
      flash[:success] = 'Mapping saved'
      flash[:saved_mapping_ids] = [@mapping.id]
      flash[:saved_operation] = "update-single"

      if Transition::OffSiteRedirectChecker.on_site?(mapping_params[:return_path])
        redirect_to mapping_params[:return_path]
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
      flash[:saved_operation] = bulk_edit.analytics_event_type
      redirect_to bulk_edit.return_path
    end
  end

  def find_global
    # This allows finding a mapping without knowing the site first.
    render_error(400) and return unless mapping_params[:url].present?

    begin
      url = Addressable::URI.parse(mapping_params[:url])
      render_error(400) and
        return unless url.scheme == "http" || url.scheme == "https"
    rescue Addressable::URI::InvalidURIError
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
    path = @site.canonical_path(mapping_params[:path])

    if path.empty?
      notice = t('mappings.not_possible_to_edit_homepage_mapping')
      return redirect_to back_or_mappings_index, notice: notice
    end

    mapping = @site.mappings.find_by_path(path)
    if mapping.present?
      redirect_to edit_site_mapping_path(@site, mapping, return_path: mapping_params[:return_path])
    else
      redirect_to new_multiple_site_mappings_path(@site, paths: path, return_path: mapping_params[:return_path])
    end
  end

private

  def mapping_params
    params.permit(:id, :site_id, :type, :operation, :return_path, :path,
                  :paths, :url, :new_url, :new_url_contains, :path_contains,
                  :mappings_batch_id, :sort, :sort_by, :suggested_url, :page,
                  :archive_url, :tagged, :tag_list, :update_existing,
                  :mapping => [
                    :type, :path, :new_url, :tag_list, :version, :state,
                    :suggested_url, :archive_url
                  ],
                  :site => [:abbr], :mapping_ids => [])
  end

  def bulk_edit
    @bulk_edit ||= bulk_editor_class.new(@site, mapping_params, site_mappings_path(@site))
  end

  def bulk_editor_class
    mapping_params[:operation] == 'tag' ? View::Mappings::BulkTagger : View::Mappings::BulkEditor
  end

  def back_or_mappings_index
    referer = request.env['HTTP_REFERER']
    if referer && Addressable::URI.parse(referer).host == request.host
      referer
    else
      site_mappings_path(@site)
    end
  end

  def check_global_redirect_or_archive
    if @site.global_type.present?
      if @site.global_redirect?
        message = "This site has been entirely redirected."
      elsif @site.global_archive?
        message = "This site has been entirely archived."
      end
      redirect_to site_path(@site), alert: "#{message} You can't edit its mappings."
    end
  end
end
