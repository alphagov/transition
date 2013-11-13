module View
  module Hits
    ##
    # The categories for hits
    class Category < Struct.new(:name, :color)
      attr_reader   :points
      attr_accessor :hits

      COLORS = {
        'all'       => '#333',
        'errors'    => '#e99',
        'archives'  => '#aaa',
        'redirects' => '#9e9',
        'other'     => '#aaa'
      }

      def self.all
        COLORS.map do |name, color|
          Category.new(name, color)
        end
      end

      def self.[](name)
        color = COLORS[name] || (raise ArgumentError, "No Category found for '#{name}'")
        Category.new(name, color)
      end

      def points=(hits)
        @points = insert_zero_hits(hits)
      end

      ##
      # Pad points with zero-count days to stop charts generating misleading slopes.
      # Requires at most one hit row per day as input - if this assumption is violated,
      # data would be lost and the graph would mislead, so we check for it.
      def insert_zero_hits(hits)
        compare_dates = lambda { |a,b| a.hit_on <=> b.hit_on }
        max_date, min_date = hits.max(&compare_dates).try(:hit_on), hits.min(&compare_dates).try(:hit_on)

        return [] if max_date.nil?

        date_hits = (min_date..max_date).inject({}) do |hash, date|
          hash[date] = nil
          hash
        end

        hits.each do |hit|
          raise ArgumentError, "expects one hit row per day, first duplicate at #{hit.hit_on}" if date_hits[hit.hit_on]
          date_hits[hit.hit_on] = hit
        end

        date_hits.keys.each do |date|
          date_hits[date] ||= Hit.new do |h|
            h.hit_on = date
            h.count = 0
          end
        end

        date_hits.values
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
