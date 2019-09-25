module Transition
  module Import
    module CSV
      class CSVSeparatorDetector
        COMMA = ",".freeze
        TAB = "\t".freeze

        def initialize(rows)
          @rows = rows.map(&:chomp)
        end

        def separator_count(separator)
          counts = @rows.map { |row| row.count(separator) }
          counts.reduce(&:+)
        end

        def comma_count
          separator_count(COMMA)
        end

        def tab_count
          separator_count(TAB)
        end

        def separator
          tab_count >= comma_count ? TAB : COMMA
        end
      end
    end
  end
end
