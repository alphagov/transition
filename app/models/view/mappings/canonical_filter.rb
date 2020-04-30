module View
  module Mappings
    ##
    # Canonicalize a URL, path or substring for use as a filter.
    # Alternatively, when not canonicalizing, just ensure the filter is a
    # path or substring, not a URL.
    class CanonicalFilter
      def initialize(site, filter)
        @site     = site
        @filter   = filter || ""
      end

      def to_s
        # Canonicalisation removes trailing slashes, which in this case
        # can be an important part of the search string. Put them back.
        @to_s ||= if @filter.ends_with?("/")
                    canonicalized + "/"
                  else
                    canonicalized
                  end
      end

    private

      def canonicalized
        if parseable_url? || path?
          @site.canonical_path(@filter)
        elsif url? # and not parseable
          @filter
        else
          canonical_substring
        end
      end

      def canonical_substring
        if @filter.starts_with?("/")
          @site.canonical_path(@filter)
        else
          # Pretend that this string is a well-formed path so it can be
          # canonicalised, by adding a leading slash. Then remove it afterwards.
          # Otherwise we would be assuming that the filter value was meant to
          # have a leading slash, which may not be the case - the user might
          # have meant to supply a fragment of a directory name.
          @site.canonical_path("/" + @filter)[1..-1]
        end
      end

      def path?
        @filter.starts_with?("/")
      end

      def url?
        @filter =~ /^https?:\/\//
      end

      def parseable_url?
        url? && Addressable::URI.parse(@filter)
      rescue Addressable::URI::InvalidURIError
        false
      end
    end

    def self.canonical_filter(site, filter)
      CanonicalFilter.new(site, filter).to_s
    end
  end
end
