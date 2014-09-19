require 'benchmark/hits/import'

namespace :benchmark do
  namespace :hits do
    desc "Time the import of hits for a given site (default #{Benchmark::Hits::Import::DEFAULT_ABBR})"
    task :import, [:abbr, :number_of_runs] => :environment do |_, args|
      Benchmark::Hits::Import.new(args[:abbr], args[:number_of_runs]).run
    end
  end
end
