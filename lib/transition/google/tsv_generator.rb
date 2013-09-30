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
      HEADER        = "date\tcount\tstatus\thost\tpath"
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
          stdfile.puts "#{HIT_NEVER_STR}\t#{count}\t000\t#{hostname}\t#{path}"
        end
      end
    end
  end
end
