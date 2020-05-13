module View
  module Hits
    ##
    # Named or arbitrary whole-day-only time periods available to view.
    # Either parsed from a valid date range string like '20130101-20130131'
    # or looked up by slug (like 'last-30-days').
    #
    # In either case use TimePeriod[string]
    class TimePeriod
      attr_reader   :slug
      attr_accessor :range_proc

      def initialize(slug, title, range_proc)
        @slug = slug
        @title = title
        self.range_proc = range_proc
      end

      def self.slugize(title)
        title.downcase.tr(" ", "-")
      end

      DATE_RANGE = /[0-9]{8}(?:-[0-9]{8})?/.freeze
      DEFAULT_SLUG = "last-30-days".freeze

      PERIODS_BY_SLUG = {
        "Yesterday" => -> { Time.zone.yesterday..Time.zone.today },
        "Last seven days" => -> { 7.days.ago.to_date..Time.zone.today },
        "Last 30 days" => -> { 30.days.ago.to_date..Time.zone.today },
        "All time" => -> { 100.years.ago.to_date..Time.zone.today },
      }.each_with_object({}) do |arr, hash|
        title, range_proc = *arr
        slug = TimePeriod.slugize(title)
        hash[slug] = TimePeriod.new(slug, title, range_proc)
      end

      def title
        @title || formatted_date
      end

      def formatted_date
        dates = [start_date]
        dates << end_date unless start_date == end_date
        dates.map { |date| date.strftime("%-d %b %Y") }.join(" - ")
      end

      def self.all(options = { exclude_all_time: false })
        PERIODS_BY_SLUG.values.reject do |p|
          options[:exclude_all_time] && p.slug == "all-time"
        end
      end

      def self.default
        PERIODS_BY_SLUG[DEFAULT_SLUG]
      end

      def self.[](slug)
        DATE_RANGE.match?(slug) ? TimePeriod.parse(slug) : PERIODS_BY_SLUG[slug]
      end

      def self.parse(range_str)
        dates = range_str.split("-")[0..1].map { |s| Date.parse(s) }
        dates[1] ||= dates[0]
        raise ArgumentError, "Invalid range, start date should be less than end date" if dates.first > dates.last

        TimePeriod.new(range_str, nil, -> { Range.new(dates.first, dates.last) })
      end

      def query_slug
        slug unless slug == DEFAULT_SLUG
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

      def single_day?
        start_date == end_date
      end

      def no_content
        slug == "all-time" ? "yet" : "in this time period"
      end
    end
  end
end
