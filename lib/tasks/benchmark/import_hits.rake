require 'date'
require 'benchmark'
require 'transition/import/hits'
require 'transition/import/console_job_wrapper'

ABBR                   = 'ukti'
TEST_FILES_MASK        = "data/pre-transition-stats/hits/www.#{ABBR}*"
DEFAULT_NUMBER_OF_RUNS = 5

def delete_hits_and_import_records
  ImportedHitsFile.delete_all("filename LIKE '#{TEST_FILES_MASK.gsub('*', '%')}'")
  /(?<date_str>[0-9]{4}-[0-9]{2}-[0-9]{2})/ =~ Dir[TEST_FILES_MASK].sort.last
  cutoff_date = Date.strptime(date_str)

  Hit.joins(:host => :site)
     .where('sites.abbr = ? AND hit_on <= ?', ABBR, cutoff_date)
     .delete_all
end

namespace :benchmark do
  desc "Time the import of hits for the #{ABBR} site"
  task :import_hits, [:number_of_runs] => :environment do |_, args|
    Transition::Import::ConsoleJobWrapper.active = false

    number_of_runs = (args[:number_of_runs] || DEFAULT_NUMBER_OF_RUNS).to_i

    puts "Timing import:hits for site #{ABBR}:\n"
    Benchmark.bm do |b|
      number_of_runs.times do
        delete_hits_and_import_records

        b.report { Transition::Import::Hits.from_redirector_mask!(TEST_FILES_MASK) }
      end
    end
  end
end
