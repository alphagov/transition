require "date"
require "benchmark"

# Hacky hacky hack hack
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../../../app")
require "controllers/application_controller"
ApplicationController.class_eval do
  def self.tracks_mappings_progress(*_args); end
end
require "controllers/hits_controller"

module Benchmark
  module Hits
    # Mock enough to make a HitsController instantiable outside
    # of a real request
    class DummyHitsController < HitsController
      attr_accessor :params

      # Without this, lazy associations like @category.hits aren't loaded,
      # and this means that the expensive database hit is never made.
      #
      # Simulate a view that enumerates them.
      def fetch_associations(action)
        case action
        when :index, :category
          @category.hits.each   { |_| }
          @category.points.each { |_| }
        when :summary
          @sections.each         { |category| category.hits.each   { |_| } }
          @point_categories.each { |category| category.points.each { |_| } }
          # /| |\
          # || ||
          # _| |_
          # Last one to get enumerated is a cyberman
        end
      end

      def set_site(abbr)
        @site = Site.find_by!(abbr: abbr)
      end

      def self.create(abbr, params)
        DummyHitsController.new.tap do |controller|
          controller.params = params
          controller.send(:set_period)
          controller.set_site(abbr)
        end
      end
    end

    class View
      DEFAULT_ABBR           = "ofsted".freeze
      DEFAULT_AREA           = "all".freeze
      AREA_ACTION            = {
        "all" => :index,
        "redirects" => :category,
        "archives" => :category,
        "errors" => :category,
        "summary" => :summary,
      }.freeze
      DEFAULT_PERIOD         = "all-time".freeze
      DEFAULT_NUMBER_OF_RUNS = 5

      attr_accessor :abbr, :area, :period, :number_of_runs

      def initialize(abbr, area, period, number_of_runs)
        self.abbr           = abbr            || DEFAULT_ABBR
        self.area           = area            || DEFAULT_AREA
        self.period         = (period         || DEFAULT_PERIOD).downcase
        self.number_of_runs = (number_of_runs || DEFAULT_NUMBER_OF_RUNS).to_i
      end

      def action
        AREA_ACTION.fetch(area)
      end

      def category
        area if %w[redirects errors archives].include?(area)
      end

      def params
        # Check we really can see the provided slug
        ::View::Hits::TimePeriod::PERIODS_BY_SLUG.fetch(period)
        { period: period }.tap do |hash|
          hash[:category] = category if category
        end
      end

      def hits_controller
        @hits_controller ||= DummyHitsController.create(abbr, params)
      end

      def run
        puts "Timing #{abbr} #{area} (#{period}):\n"
        Benchmark.bm do |b|
          number_of_runs.times do
            b.report do
              hits_controller.send               action
              hits_controller.fetch_associations(action)
            end
          end
        end
      end
    end
  end
end
