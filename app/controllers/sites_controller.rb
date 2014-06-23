class SitesController < ApplicationController
  def show
    @site = Site.find_by_abbr!(params[:id])
    @most_used_tags = @site.most_used_tags
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
  end
end
