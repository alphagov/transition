module Transition
  class OffSiteRedirectChecker
    def self.on_site?(location)
      # Someone could craft a link to the transition app with a malicious
      # return_path which would result in the user ending up on their site.
      #
      # Some clients (eg Firefox and Chrome) will happily accept an absolute URL
      # which starts with ///, eg ///host.com
      # This is also true with // - a "protocol-relative URL". More information:
      # http://homakov.blogspot.co.uk/2014/01/evolution-of-open-redirect-vulnerability.html?m=1

      return false if location.blank?

      location.start_with?("/") && !location.start_with?("//")
    end
  end
end
