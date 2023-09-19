require "./lib/transition/import/revert_entirely_unsafe"

class SitesController < ApplicationController
  layout "admin_layout", only: %w[new create edit]

  before_action :find_site, only: %i[edit update show confirm_destroy destroy]
  before_action :find_organisation, only: %i[new create]
  before_action :check_user_is_site_manager, only: %i[new create confirm_destroy destroy edit update]

  def new
    @site_form = SiteForm.new(organisation_slug: @organisation.whitehall_slug)
  end

  def create
    @site_form = SiteForm.new(create_or_update_params)

    if (site = @site_form.save)
      redirect_to site_path(site), flash: { success: "Transition site created" }
    else
      render :new
    end
  end

  def edit
    @organisation = @site.organisation

    @site_form = SiteForm.new(
      organisation_slug: @organisation.whitehall_slug,
      abbr: @site.abbr,
      tna_timestamp: @site.tna_timestamp.to_formatted_s(:number),
      homepage: @site.homepage,
      extra_organisations: @site.extra_organisations,
      homepage_title: @site.homepage_title,
      homepage_furl: @site.homepage_furl,
      global_type: @site.global_type,
      global_new_url: @site.global_new_url,
      global_redirect_append_path: @site.global_redirect_append_path,
      query_params: @site.query_params,
      special_redirect_strategy: @site.special_redirect_strategy,
      hostname: @site.default_host.hostname,
      aliases: @site.hosts_excluding_primary_and_aka.map(&:hostname).join(","),
    )
  end

  def update
    @site_form = SiteForm.new(create_or_update_params)

    if (site = @site_form.save)
      redirect_to site_path(site), flash: { success: "Transition site updated" }
    else
      ## TODO: need to show the error on the form, possibly use render instead of redirect_to
      redirect_to edit_site_path(@site), alert: @site_form.errors.full_messages
    end
  end

  def show
    @most_used_tags = @site.most_used_tags(10)
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
    @unresolved_mappings_count = @site.mappings.unresolved.count
  end

  def confirm_destroy; end

  def destroy
    if params[:confirm_destroy] == @site.abbr
      Transition::Import::RevertEntirelyUnsafe::RevertSite.new(@site).revert_all_data!
      redirect_to organisation_path(@site.organisation), flash: { success: "The site and all its data have been successfully deleted" }
    else
      redirect_to confirm_destroy_site_path(@site), flash: { alert: "The confirmation did not match" }
    end
  end

private

  def find_site
    @site = Site.find_by!(abbr: params[:id])
  end

  def find_organisation
    @organisation = Organisation.find_by(whitehall_slug: params[:organisation_id])
  end

  def create_or_update_params
    params.require(:site_form).permit(
      :organisation_slug,
      :abbr,
      :tna_timestamp,
      :homepage,
      :homepage_title,
      :global_type,
      :global_new_url,
      :global_redirect_append_path,
      :homepage_furl,
      :hostname,
      :query_params,
      :special_redirect_strategy,
      :aliases,
      extra_organisations: [],
    )
  end

  def update_params
    params.require(:site).permit(:launch_date)
  end

  def check_user_is_site_manager
    unless current_user.site_manager?
      message = "Only Site Managers can access that."
      redirect_to redirect_path, alert: message
    end
  end

  def redirect_path
    if @site
      site_path(@site)
    else
      organisation_path(@organisation)
    end
  end
end
