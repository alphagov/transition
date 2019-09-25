require "transition/import/materialized_views/hits"

namespace :import do
  namespace :hits do
    desc "Refresh materialized views for all hits, all-time on larger sites"
    task refresh_materialized: :environment do
      Transition::DistributedLock.new("refresh_materialized_views").lock do
        Transition::Import::MaterializedViews::Hits.replace!
      end
    end
  end
end
