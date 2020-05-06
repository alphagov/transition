module Transition
  class PathOrUrl
    STARTS_WITH_HTTP_SCHEME = %r{^https?://}.freeze

    # TLDs for Hosts in transition
    TLDS = %w[
      .co.uk
      .com
      .gov.uk
      .ie
      .info
      .mod.uk
      .net
      .nhs.uk
      .org
      .org.uk
      .police.uk
      .tv
    ].freeze

    def self.starts_with_http_scheme?(path_or_url)
      path_or_url =~ STARTS_WITH_HTTP_SCHEME
    end

    def self.starts_with_a_domain?(path_or_url)
      first_part = path_or_url.split("/").first

      escaped_tlds = TLDS.map { |tld| Regexp.escape(tld) }
      first_part =~ Regexp.new("#{escaped_tlds.join('|')}$")
    end
  end
end
