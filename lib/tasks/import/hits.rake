require 'transition/import/hits'
require 'transition/import/daily_hit_totals'

namespace :import do
  desc 'Import hits for a file or mask'
  task :hits, [:filename_or_mask] => :environment do |_, args|
    filename_or_mask = args[:filename_or_mask]
    done = Transition::Import::Hits.from_mask!(filename_or_mask)
    if done > 0
      Transition::Import::DailyHitTotals.from_hits!
      Transition::Import::HitsMappingsRelations.refresh!
    end
  end

  desc 'Import hits from sql table by date'
  task :sql_hits, [:date] => :environment do |_, args|
    date = args[:date]
    Transition::Import::RawSqlHits.update!(date)
    Transition::Import::DailyHitTotals.from_hits!
    Transition::Import::HitsMappingsRelations.refresh!
  end
end
