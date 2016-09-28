# From the rake task, for some reason, app/models/hit.rb is not loaded,
# despite the => :environment dependency. This is a workaround.
# If you can remove it and make rake ingest:ga work, I owe you gelato.
# (substitute delicacy of your choice for the lactose-intolerant)
require_relative '../../../app/models/hit'

module Transition
  module Google
    ##
    # Given a +results_pager+ that behaves like an +Enumerable+ returning a stream
    # of +[<hostname>, <path>, <count>]+ arrays and a +stdfile+ to send them to,
    # +generate!+ a tab-separated list of pseudo-+Hit+s
    #
    # This exists so we can reuse the TSV-based fast mySQL import of Hits
    class TSVGenerator
      HEADER        = "date\tcount\tstatus\thost\tpath".freeze
      HIT_NEVER_STR = Hit::NEVER.strftime('%Y-%m-%d')

      attr_accessor :results_pager, :stdfile

      def initialize(results_pager, stdfile)
        self.results_pager = results_pager
        self.stdfile       = stdfile
      end

      ##
      # Generate the list in +results_pager+ to +stdfile+
      def generate!
        stdfile.puts HEADER
        results_pager.each do |hostname, path, count|
          stdfile.puts "#{HIT_NEVER_STR}\t#{count}\t000\t#{hostname}\t#{path}" if count >= 10
        end
      end
    end
  end
end
