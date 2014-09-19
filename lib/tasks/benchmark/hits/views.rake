require 'benchmark/hits/all_hits_all_time'

namespace :benchmark do
  namespace :hits do
    desc "Time the data access portion of the viewing of hits "
         "for a given site (defaults to '#{Benchmark::Hits::AllHitsAllTime::DEFAULT_ABBR}')"
    task :all_time, [:site_abbr,:number_of_runs] => :environment do |_, args|
      # This task is indicative at best.
      # It creates just enough to make a controller viable for data access,
      # and does not time the ActionView portion at all.
      Benchmark::Hits::AllHitsAllTime.new(
        args[:site_abbr],
        args[:number_of_runs]
      ).run
    end
  end
end
