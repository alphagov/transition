class SitesController < ApplicationController
  before_action :find_site
  before_action :check_user_is_gds_editor, only: %i[edit update]

  def edit; end

  def update
    if @site.update(site_params)
      redirect_to site_path(@site), flash: { success: "Transition date updated" }
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

  def check_user_is_gds_editor
    unless current_user.gds_editor?
      message = "Only GDS Editors can access that."
      redirect_to site_path(@site), alert: message
    end
  end
end
