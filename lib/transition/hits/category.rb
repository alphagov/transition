module Transition
  module Hits
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
        Category.new(name, COLORS[name])
      end

      def points=(hits)
        @points = insert_zero_hits(hits)
      end

      def insert_zero_hits(hits)
        compare_dates = lambda { |a,b| a.hit_on <=> b.hit_on }
        max_date, min_date = hits.max(&compare_dates).hit_on, hits.min(&compare_dates).hit_on

        date_hits = (min_date..max_date).inject({}) do |hash, date|
          hash[date] = nil
          hash
        end

        hits.each { |hit| date_hits[hit.hit_on] = hit }

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
    end
  end
end
