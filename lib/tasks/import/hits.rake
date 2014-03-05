require 'transition/import/hits'
require 'transition/import/daily_hit_totals'

namespace :import do
  desc 'Import redirector hits for a file or mask'
  task :hits, [:filename_or_mask] => :environment do |_, args|
    filename_or_mask = args[:filename_or_mask]
    Transition::Import::Hits.from_redirector_mask!(filename_or_mask)
    Transition::Import::DailyHitTotals.from_hits!
    Transition::Import::HitsMappingsRelations.refresh!
  end
end
