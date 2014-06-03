class SitesController < ApplicationController
  def show
    @site = Site.find_by_abbr!(params[:id])
    @hosts = @site.hosts.excluding_aka.includes(:aka_host)
  end
end
