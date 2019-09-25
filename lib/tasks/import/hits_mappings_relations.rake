require "transition/import/hits_mappings_relations"

namespace :import do
  desc "Dev only: refresh c14nd path relations between hits and mappings"
  task hits_mappings_relations: :environment do
    Transition::Import::HitsMappingsRelations.refresh!
  end
end
