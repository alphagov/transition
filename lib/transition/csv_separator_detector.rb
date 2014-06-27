module Transition
  class CSVSeparatorDetector
    COMMA = ','
    TAB = "\t"

    def initialize(rows)
      @rows = rows.map(&:chomp)
    end

    def separator_count(separator)
      counts = @rows.map { |row| row.count(separator) }
      counts.inject { |sum, count| sum + count }
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
