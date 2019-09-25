require "transition/export/foi_response"

namespace :export do
  desc "Export sites, hosts and mappings data for FOI response"
  task foi_response: :environment do
    Transition::Export::FOIResponse.export!
  end
end
