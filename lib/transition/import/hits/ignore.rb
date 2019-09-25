module Transition
  module Import
    class Hits
      class Ignore
        # Lines should probably never be removed from this, only added.
        PATHS = [
          # Generic site furniture
          "/browserconfig.xml",
          "/favicon.ico",
          "/robots.txt",
          "/sitemap.xml",

          # Used in our smokey tests
          "/gdssupertestfakeurl",
          "/thisshouldntwork",
          "/whateverthisshouldntwork",

          # Spam
          "/admin.php",
          "/admin/admin.php",
          "/admin/password_forgotten.php?action=execute",
          "/administrator/index.php",
          # Found in www.ukti.gov.uk logs. See: http://www.spambotsecurity.com/forum/viewtopic.php?p=15489&sid=83d6bc4bcddff28b0e124687e4d8a741#p15489
          "//images/stories/0d4y.php",
          "//images/stories/0day.php",
          "//images/stories/3xp.php",
          "//images/stories/70bex.php",
          "//images/stories/iam.php",
          "//images/stories/itil.php",
          "//images/stories/jahat.php",
        ].freeze

        PATTERNS = [
          # Generic site furniture
          '.*\.css',
          '.*\.js(\W|$)',
          '.*\.gif',
          '.*\.ico',
          '.*\.jpg',
          '.*\.jpeg',
          '.*\.png',
          '.*\.svg',

          # Font files
          '.*\.eot',
          '.*\.ttf',
          '.*\.woff',

          # Image URLs on www.ukti.gov.uk
          '^/[0-9]+\.image$',
          '^/[0-9]+\.leadimage\?.*',

          # Often after transition, bots seem to think the old site has
          # www.gov.uk URLs.
          # There are definitely other www.gov.uk URLs, but they are harder to
          # automatically exclude.
          # Whilst we were able to find two *.gov.uk sites using /browse/ or
          # /government/ the numbers of URLs were very small and they are not
          # sites which will transition to GOV.UK.
          "/browse/.*",
          "/government/.*",

          # This is used by TNA to resolve pages which are missing from their archive:
          # http://www.nationalarchives.gov.uk/documents/information-management/redirection-technical-guidance-for-departments-v4.2-web-version.pdf
          "/ukgwacnf.html.*",

          # Spam
          '.*\.bat',
          '.*\.htpasswd',
          '.*\.ini',
          ".*/etc/passwd.*",
          ".*/proc/self/environ.*",
          ".*phpMyAdmin.*",
          ".*sqlpatch.php.*",
          ".*_vti_bin.*",
          ".*_vti_inf.htm",
          ".*_vti_pvt.*",
          ".*_vti_rpc",
          ".*wp-admin.*",
          ".*wp-cron.*",
          ".*wp-login.*",
        ].freeze
      end
    end
  end
end
