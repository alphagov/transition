require "transition/import/daily_hit_totals"

namespace :import do
  desc "Refresh totals from hits"
  task daily_hit_totals: :environment do
    Transition::Import::DailyHitTotals.from_hits!
  end
end
