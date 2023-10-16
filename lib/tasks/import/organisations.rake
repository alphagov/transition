require "transition/import/organisations"

namespace :import do
  desc "Import all Organisations"
  task organisations: :environment do
    Transition::Import::Organisations.from_whitehall!
  end
end
