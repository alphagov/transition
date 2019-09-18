class SitesController < ApplicationController
  before_action :find_site, only: %i[edit update show]
  before_action :check_user_is_gds_editor, only: %i[edit update]

  def new
    @site = Site.new(organisation: organisation)
  end

  def create
    @site = Site.create(site_params.merge(tna_timestamp: Time.zone.now))
    if @site.valid?
      create_host
      redirect_to site_path(@site), flash: { success: 'Created a new site!' }
    else
      render :new, flash: { alert: "We couldn't save your site" }
    end
  end

  def edit; end

  def update
    if @site.update(site_params)
      redirect_to site_path(@site), flash: { success: 'Site updated successfully' }
    else
      render :edit, flash: { alert: "We couldn't save your change" }
    end
  end

  def show
    @most_used_tags = @site.most_used_tags(10)
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
    @unresolved_mappings_count = @site.mappings.unresolved.count
  end

  private def create_host
    hosts = params[:host_names]
    return unless hosts.present?

    host_list = hosts.split(',')
    host_list.each do |host|
      Host.create(hostname: host, cname: host, site: @site).save
    end
  end

  private def organisation
    Organisation.find_by_whitehall_slug!(params[:organisation])
  end

  def find_site
    @site = Site.find_by_abbr!(params[:id])
  end

  def site_params
    params.require(:site).permit \
      :launch_date,
      :abbr,
      :query_params,
      :homepage,
      :global_new_url,
      :global_redirect_append_path,
      :homepage_title,
      :homepage_furl,
      :organisation_id,
      :host_names
  end

  private def check_user_is_gds_editor
    unless current_user.gds_editor?
      message = 'Only GDS Editors can access that.'
      redirect_to site_path(@site), alert: message
    end
  end
end
