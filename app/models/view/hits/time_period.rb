module View
  module Hits
    ##
    # The fixed time periods available to view
    class TimePeriod < Struct.new(:title, :range_proc)
      def self.slugize(title)
        title.downcase.gsub(' ', '-')
      end

      PERIODS_BY_SLUG = {
        'Yesterday'       => lambda { Date.yesterday..Date.today },
        'Last seven days' => lambda { 7.days.ago.to_date..Date.today },
        'Last 30 days'    => lambda { 30.days.ago.to_date..Date.today },
        'All time'        => lambda { 100.years.ago.to_date..Date.today }
      }.inject({}) do |hash, arr|
        title, range_proc = *arr
        hash[TimePeriod.slugize(title)] = TimePeriod.new(title, range_proc)
        hash
      end

      def self.all
        PERIODS_BY_SLUG.values
      end

      def self.default
        PERIODS_BY_SLUG['all-time']
      end

      def self.[](slug)
        PERIODS_BY_SLUG[slug]
      end

      def slug
        TimePeriod.slugize(title)
      end

      def query_slug
        slug unless slug == 'all-time'
      end

      def range
        range_proc.call
      end

      def start_date
        range.min
      end

      def end_date
        range.max
      end

      def no_content
        slug == 'all-time' ? 'yet' : 'in this time period'
      end
    end
  end
end
