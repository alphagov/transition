module Transition
  module Hits
    class Category < Struct.new(:name, :color)
      attr_accessor :hits, :points

      COLORS = {
        'all'       => '#999',
        'errors'    => '#e99',
        'redirects' => '#9e9',
        'archives'  => '#aaa',
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

      def to_sym
        name.to_sym
      end

      def title
        name.capitalize
      end
    end
  end
end
