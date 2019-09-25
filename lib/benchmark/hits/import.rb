require "date"
require "benchmark"
require "transition/import/hits"
require "transition/import/console_job_wrapper"

module Benchmark
  module Hits
    class Import
      DEFAULT_ABBR           = "ukti".freeze
      DEFAULT_NUMBER_OF_RUNS = 5

      attr_accessor :abbr, :number_of_runs

      def initialize(abbr, number_of_runs)
        self.abbr           = abbr || DEFAULT_ABBR
        self.number_of_runs = (number_of_runs || DEFAULT_NUMBER_OF_RUNS).to_i
      end

      def test_files_mask
        "data/pre-transition-stats/hits/www.#{abbr}*"
      end

      def run
        Transition::Import::ConsoleJobWrapper.active = false

        puts "Timing import:hits for site #{abbr}:\n"
        Benchmark.bm do |b|
          number_of_runs.times do
            delete_hits_and_import_records

            b.report { Transition::Import::Hits.from_mask!(test_files_mask) }
          end
        end
      end

    private

      def delete_hits_and_import_records
        ImportedHitsFile.delete_all("filename LIKE ?", test_files_mask.tr("*", "%"))
        /(?<date_str>[0-9]{4}-[0-9]{2}-[0-9]{2})/ =~ Dir[test_files_mask].max
        cutoff_date = Date.strptime(date_str)

        Hit.joins(host: :site)
           .where("sites.abbr = ? AND hit_on <= ?", abbr, cutoff_date)
           .delete_all
      end
    end
  end
end
