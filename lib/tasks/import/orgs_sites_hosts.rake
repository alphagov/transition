require "transition/import/orgs_sites_hosts"

namespace :import do
  desc "Import all Organisations"
  task organisations: :environment do
    Transition::Import::Organisations.from_yaml!
  end
end
