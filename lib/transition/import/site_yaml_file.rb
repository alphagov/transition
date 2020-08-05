require "htmlentities"

module Transition
  module Import
    class SiteYamlFile
      attr_accessor :yaml

      def initialize(yaml)
        self.yaml = yaml
      end

      def import!
        import_site!
        import_hosts!
      end

      def abbr
        yaml["site"]
      end

      def aliases
        yaml["aliases"] && yaml["aliases"].map(&:downcase)
      end

      def extra_organisation_slugs
        yaml["extra_organisation_slugs"]
      end

      def host
        yaml["host"].downcase
      end

      def whitehall_slug
        yaml["whitehall_slug"]
      end

      def title
        HTMLEntities.new.decode(yaml["title"])
      end

      def has_global_type?
        # cdn.hm-treasury.gov.uk has a regex in the global value, which Bouncer
        # implements as a "rule", so we can ignore it.
        yaml["global"] && (host != "cdn.hm-treasury.gov.uk")
      end

      def global_type
        # There are two expected formats of the 'global' value:
        # global: =301 https://secure.fera.defra.gov.uk/nonnativespecies/beplantwise/
        #
        # or:
        # global: =410
        if has_global_type?
          case yaml["global"].split(" ")[0].delete("=")
          when "301" then "redirect"
          when "410" then "archive"
          end
        end
      end

      def global_new_url
        yaml["global"].split(" ")[1] if has_global_type?
      end

      def global_redirect_append_path
        yaml["global_redirect_append_path"].present?
      end

      attr_reader :site
      def import_site!
        @site = Site.where(abbr: abbr).first_or_initialize.tap do |site|
          # transition-config uses slugs to identify organisations because
          # content_ids are user-unfriendly and add complexity. We think it will
          # be very infrequent that an organisation with a slug change will be
          # in transition-config.
          site.organisation          = Organisation.find_by(whitehall_slug: whitehall_slug)

          site.tna_timestamp         = Time.strptime(yaml["tna_timestamp"].to_s, "%Y%m%d%H%M%S")
          site.query_params          = yaml["options"] ? yaml["options"].sub(/^.*--query-string /, "") : ""
          site.global_type           = global_type
          site.global_new_url        = global_new_url
          site.global_redirect_append_path = global_redirect_append_path
          site.homepage              = yaml["homepage"]
          site.homepage_title        = yaml["homepage_title"]
          site.homepage_furl         = yaml["homepage_furl"]
          site.special_redirect_strategy = yaml["special_redirect_strategy"]

          site.save!
        end
        # Again, transition-config uses slugs to identify organisations
        @site.extra_organisations = Organisation.where(whitehall_slug: extra_organisation_slugs)
      end

      def import_hosts!
        [host, aliases].flatten.compact.each do |name|
          canonical_host = Host.where(hostname: name).first_or_initialize
          canonical_host.site = site
          canonical_host.save!

          aka_name = canonical_host.aka_hostname
          aka_host = Host.where(hostname: aka_name).first_or_initialize
          aka_host.site = site
          aka_host.canonical_host_id = canonical_host.id
          aka_host.save!
        end
      end

      def self.load(yaml_filename)
        SiteYamlFile.new(YAML.safe_load(File.read(yaml_filename)))
      end
    end
  end
end
