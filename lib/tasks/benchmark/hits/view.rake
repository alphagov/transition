require "benchmark/hits/view"

namespace :benchmark do
  namespace :hits do
    desc "Time the data access portion of the viewing of hits "\
    "for a given site (defaults to '#{Benchmark::Hits::View::DEFAULT_ABBR}')"
    task :view, %i[site_abbr hits_area period number_of_runs] => :environment do |_, args|
      # This task is indicative at best.
      # It creates just enough to make a controller viable for data access,
      # and does not time the ActionView portion at all.
      Benchmark::Hits::View.new(
        args[:site_abbr],
        args[:hits_area],
        args[:period],
        args[:number_of_runs],
      ).run
    end
  end
end
