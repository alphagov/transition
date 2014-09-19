require 'date'
require 'benchmark'

# Hacky hacky hack hack
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../../../app')
require 'controllers/application_controller'
ApplicationController.class_eval do
  def self.tracks_mappings_progress(*args); end
end
require 'controllers/hits_controller'

module Benchmark
  module Hits
    # Mock enough to make a HitsController instantiable outside
    # of a real request
    class DummyHitsController < HitsController
      def params
        { period: 'all-time' }
      end

      # Without this, lazy associations like @category.hits aren't loaded,
      # and this means that the expensive database hit is never made.
      #
      # Simulate a view that enumerates them.
      def fetch_associations
        @category.hits.each {|_|} # cyberman head
                          # /| |\
                          # || ||
                          # _| |_ # may as well finish him
      end

      def set_site(abbr)
        @site = Site.find_by!(abbr: abbr)
      end

      def self.create(abbr)
        DummyHitsController.new.tap do |controller|
          controller.send(:set_period)
          controller.set_site(abbr)
        end
      end
    end

    class AllHitsAllTime
      DEFAULT_ABBR           = 'ofsted'
      DEFAULT_NUMBER_OF_RUNS = 5

      attr_accessor :abbr, :number_of_runs

      def initialize(abbr, number_of_runs)
        self.abbr           = abbr || DEFAULT_ABBR
        self.number_of_runs = (number_of_runs || DEFAULT_NUMBER_OF_RUNS).to_i
      end

      def hits_controller
        @_controller ||= DummyHitsController.create(abbr)
      end

      def run
        puts "Timing All hits/period=all-time for site #{abbr}:\n"
        Benchmark.bm do |b|
          number_of_runs.times do
            b.report do
              hits_controller.index
              hits_controller.fetch_associations
            end
          end
        end
      end
    end
  end
end
