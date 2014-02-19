class GlossaryController < ApplicationController

  def index

    @example_site = Site.where(abbr: 'cabinetoffice').first
    @example_archive = Mapping.where(http_status: '410').first
    @example_redirect = @example_site.mappings.where(http_status: '301').first

  end

end
