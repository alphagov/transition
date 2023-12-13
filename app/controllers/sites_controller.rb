class SitesController < ApplicationController
  layout "admin_layout", except: %w[show]

  include PaperTrail::Rails::Controller

  before_action :find_site, except: %i[new create]
  before_action :find_organisation, only: %i[new create edit]
  before_action :check_user_is_site_manager, except: %i[show]

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
    @site_form = SiteForm.for_existing(@site)
  end

  def update
    @site_form = SiteForm.new(create_or_update_params)

    if (site = @site_form.save)
      redirect_to site_path(site), flash: { success: "Transition site updated" }
    else
      render :edit
    end
  end

  def show
    @most_used_tags = @site.most_used_tags(10)
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
    @unresolved_mappings_count = @site.mappings.unresolved.count
  end

  def confirm_destroy
    @delete_site_form = DeleteSiteForm.new
  end

  def destroy
    @delete_site_form = DeleteSiteForm.new(id: @site.id, **destroy_params)

    if @delete_site_form.save
      redirect_to organisation_path(@site.organisation), flash: { success: "The site and all its data have been successfully deleted" }
    else
      render :confirm_destroy
    end
  end

private

  def find_site
    @site = Site.find_by_abbr_or_id(params[:id])
  end

  def find_organisation
    @organisation = Organisation.find_by(whitehall_slug: params[:organisation_id])
  end

  def create_or_update_params
    params.require(:site_form).permit(
      :site_id,
      :organisation_slug,
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

  def destroy_params
    params.require(:delete_site_form).permit(:hostname_confirmation)
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
