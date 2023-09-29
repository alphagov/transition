class SiteDatesController < ApplicationController
  layout "admin_layout"

  before_action :find_site
  before_action :check_user_is_gds_editor

  def edit
    @site_date_form = SiteDateForm.new(
      site: @site,
      "launch_date(3i)": @site.launch_date&.day,
      "launch_date(2i)": @site.launch_date&.month,
      "launch_date(1i)": @site.launch_date&.year,
    )
  end

  def update
    @site_date_form = SiteDateForm.new(site: @site, **update_params)
    if @site_date_form.save
      redirect_to site_path(@site), flash: { success: "Transition date updated" }
    else
      render :edit
    end
  end

private

  def find_site
    @site = Site.find_by!(abbr: params[:site_id])
  end

  def update_params
    params.require(:site).permit("launch_date(3i)", "launch_date(2i)", "launch_date(1i)")
  end

  def check_user_is_gds_editor
    unless current_user.gds_editor?
      message = "Only GDS Editors can access that."
      redirect_to site_path(@site), alert: message
    end
  end
end
