require 'transition/import/hits_mappings_relations'

namespace :import do
  desc 'Refresh c14nd path relations between hits and mappings'
  task :hits_mappings => :environment do
    Transition::Import::HitsMappingsRelations.refresh!
  end
end
