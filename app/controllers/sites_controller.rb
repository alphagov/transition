class SitesController < ApplicationController
  before_filter :find_site

  def show
  end

private
  def find_site
    @site = Site.find_by_abbr(params[:id])
  end
end
