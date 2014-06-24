class SitesController < ApplicationController
  def show
    @site = Site.find_by_abbr!(site_params[:id])
    @most_used_tags = @site.most_used_tags
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
    @unresolved_mappings_count = @site.mappings.unresolved.count
  end

  private
  def site_params
    params.permit(:id)
  end
end
