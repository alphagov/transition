class SiteDatesController < ApplicationController
  before_action :find_site
  before_action :check_user_is_gds_editor

  def edit; end

  def update
    if @site.update(update_params)
      redirect_to site_path(@site), flash: { success: "Transition date updated" }
    else
      redirect_to edit_site_path(@site), flash: { alert: "We couldn't save your change" }
    end
  end

private

  def find_site
    @site = Site.find_by!(abbr: params[:site_id])
  end

  def update_params
    params.require(:site).permit(:launch_date)
  end

  def check_user_is_gds_editor
    unless current_user.gds_editor?
      message = "Only GDS Editors can access that."
      redirect_to site_path(@site), alert: message
    end
  end
end
