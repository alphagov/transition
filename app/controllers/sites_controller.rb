class SitesController < ApplicationController
  before_filter :find_site

  def edit
    if !current_user.gds_editor?
      redirect_to site_path(@site), flash: { alert: "You don't have permission to edit transition dates" }
    end
  end

  def update
    @site.launch_date = site_params[:launch_date]
    if @site.save
      redirect_to site_path(@site), flash: { success: 'Transition date updated' }
    else
      redirect_to edit_site_path(@site), flash: { alert: "We couldn't save your change" }
    end
  end

  def show
    @most_used_tags = @site.most_used_tags(10)
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
    @unresolved_mappings_count = @site.mappings.unresolved.count
  end

private
  def find_site
    @site = Site.find_by_abbr!(params[:id])
  end

  def site_params
    params.require(:site).permit(:launch_date)
  end
end
