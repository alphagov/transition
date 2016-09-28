require 'transition/google/results_pager'
require 'transition/google/tsv_generator'
require 'transition/import/hits'

module Transition
  module Google
    ##
    # Ingest a set of GA URLs to the Hit model.
    #
    # Example usage:
    #   Ingester.new('dpm').ingest!
    class UrlIngester
      PAGE_SIZE = 10000

      attr_accessor :start_date, :end_date

      def initialize(
        whitehall_slug,
        start_date = 6.months.ago,
        end_date = Time.zone.today.end_of_day
      )
        @whitehall_slug = whitehall_slug

        self.start_date = start_date
        self.end_date   = end_date
      end

      def check_organisation!
        raise RuntimeError, 'Organisation has no Google Analytics profile ID' unless organisation.ga_profile_id.present?
      end

      def organisation
        @organisation ||= Organisation.find_by_whitehall_slug!(@whitehall_slug)
      end

      def results_pager
        @pager ||= Transition::Google::ResultsPager.new(parameters)
      end

      def parameters
        {
          'ids'         => "ga:#{organisation.ga_profile_id}",
          'start-date'  => start_date.strftime('%Y-%m-%d'),
          'end-date'    => end_date.strftime('%Y-%m-%d'),
          'dimensions'  => 'ga:hostname,ga:pagePath',
          'metrics'     => 'ga:pageViews',
          'max-results' => PAGE_SIZE
        }
      end

      def list(output = $stdout)
        check_organisation!

        begin
          begin
            TSVGenerator.new(results_pager, output).generate!
          ensure
            output.close if output.respond_to?(:close)
          end

          yield output if block_given?
        ensure
          output.unlink if output.respond_to?(:unlink)
        end
      end

      def ingest!(output_file = Tempfile.new('hit-ingest'))
        list(output_file) do |output|
          Transition::Import::Hits.from_tsv!(output.path)
        end
      end
    end
  end
end
