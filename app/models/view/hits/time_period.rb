module View
  module Hits
    ##
    # The fixed time periods available to view
    class TimePeriod
      attr_reader   :slug
      attr_accessor :range_proc

      def initialize(slug, title, range_proc)
        @slug = slug
        @title = title
        self.range_proc = range_proc
      end

      def self.slugize(title)
        title.downcase.gsub(' ', '-')
      end

      DATE_RANGE = /[0-9]{8}(?:-[0-9]{8})?/

      PERIODS_BY_SLUG = {
        'Yesterday'       => lambda { Date.yesterday..Date.today },
        'Last seven days' => lambda { 7.days.ago.to_date..Date.today },
        'Last 30 days'    => lambda { 30.days.ago.to_date..Date.today },
        'All time'        => lambda { 100.years.ago.to_date..Date.today }
      }.inject({}) do |hash, arr|
        title, range_proc = *arr
        slug = TimePeriod.slugize(title)
        hash[slug] = TimePeriod.new(slug, title, range_proc)
        hash
      end

      def title
        @title || formatted_date
      end

      def formatted_date
        dates = [start_date]
        dates << end_date unless start_date == end_date
        dates.map { |date| date.strftime('%-d %b %Y') }.join(' - ')
      end

      def self.all
        PERIODS_BY_SLUG.values
      end

      def self.default
        PERIODS_BY_SLUG['all-time']
      end

      def self.[](slug)
        slug =~ DATE_RANGE ?  TimePeriod.parse(slug) : PERIODS_BY_SLUG[slug]
      end

      def self.parse(range_str)
        dates = range_str.split('-')[0..1].map { |s| Date.parse(s) }
        dates[1] ||= dates[0]
        raise ArgumentError, 'Invalid range, start date should be less than end date' if dates.first > dates.last
        TimePeriod.new(range_str, nil, lambda { Range.new(dates.first, dates.last) })
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
