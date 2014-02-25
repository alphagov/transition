module View
  module Hits
    ##
    # The categories for hits
    class Category < Struct.new(:name, :color)
      attr_reader :hits, :points

      COLORS = {
        'all'       => '#333',
        'errors'    => '#e99',
        'archives'  => '#aaa',
        'redirects' => '#9e9'
      }

      def hits=(scope)
        @hits = (name == 'errors') ? scope.without_mappings : scope
      end

      def self.all
        COLORS.map do |name, color|
          Category.new(name, color)
        end
      end

      def self.[](name)
        color = COLORS[name] || (raise ArgumentError, "No Category found for '#{name}'")
        Category.new(name, color)
      end

      def points=(totals)
        @points = insert_zero_totals(totals)
      end

      ##
      # Pad points with zero-count days to stop charts generating misleading slopes.
      # Requires at most one total row per day as input - if this assumption is violated,
      # data would be lost and the graph would mislead, so we check for it.
      def insert_zero_totals(totals)
        compare_dates = lambda { |a,b| a.total_on <=> b.total_on }
        max_date, min_date = totals.max(&compare_dates).try(:total_on), totals.min(&compare_dates).try(:total_on)

        return [] if max_date.nil?

        date_totals = (min_date..max_date).inject({}) do |hash, date|
          hash[date] = nil
          hash
        end

        totals.each do |total|
          if date_totals[total.total_on]
            raise ArgumentError, "expects one total row per day, first duplicate at #{total.total_on}"
          end
          date_totals[total.total_on] = total
        end

        date_totals.keys.each do |date|
          date_totals[date] ||= DailyHitTotal.new do |h|
            h.total_on = date
            h.count = 0
          end
        end

        date_totals.values
      end

      def to_sym
        name.to_sym
      end

      def title
        name == 'all' ? 'All hits' : name.capitalize
      end

      def plural
        name == 'all' ? 'hits' : name.pluralize
      end

      def path_method
        name == 'all' ? :site_hits_path : "#{name}_site_hits_path".to_sym
      end
    end
  end
end
