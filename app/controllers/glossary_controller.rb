class GlossaryController < ApplicationController
  def index
    @example_site = Site.where(abbr: "cabinetoffice").first
    @example_archive = Mapping.where(type: "archive").first
    @example_redirect = Mapping.where(type: "redirect").first
  end
end
