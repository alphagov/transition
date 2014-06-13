require 'htmlentities'

module Transition
  module Import
    ##
    # A transition-centric view over redirector yaml
    class SiteYamlFile
      attr_accessor :yaml
      attr_writer   :managed_by_transition

      def initialize(yaml, managed_by_transition)
        self.yaml = yaml
        self.managed_by_transition = managed_by_transition
      end

      def import!
        import_site!
        import_hosts!
      end

      def abbr
        yaml['site']
      end

      def extra_organisation_slugs
        yaml['extra_organisation_slugs']
      end

      def whitehall_slug
        yaml['whitehall_slug'] || case abbr
                                    when /^directgov.*/ then 'directgov'
                                    when /^businesslink.*/ then 'business-link'
                                  end
      end

      def title
        HTMLEntities.new.decode(yaml['title'])
      end

      def has_global_type?
        # cdn.hm-treasury.gov.uk has a regex in the global value, which Bouncer
        # implements as a "rule", so we can ignore it.
        yaml['global'] && (yaml['host'] != 'cdn.hm-treasury.gov.uk')
      end

      def global_type
        # There are two expected formats of the 'global' value:
        # global: =301 https://secure.fera.defra.gov.uk/nonnativespecies/beplantwise/
        #
        # or:
        # global: =410
        if has_global_type?
          case yaml['global'].split(' ')[0].gsub("=", "")
            when '301' then 'redirect'
            when '410' then 'archive'
          end
        end
      end

      def global_new_url
        yaml['global'].split(' ')[1] if has_global_type?
      end

      def global_redirect_append_path
        !! yaml['global_redirect_append_path']
      end

      def managed_by_transition?
        # Always exactly true/false values, not just "falsey"
        # - this is also going to the DB, which won't allow nil
        !!@managed_by_transition
      end

      attr_reader :site
      def import_site!
        @site = Site.where(abbr: abbr).first_or_initialize.tap do |site|
          site.organisation          = Organisation.find_by_whitehall_slug(whitehall_slug)

          site.launch_date           = yaml['redirection_date']
          site.tna_timestamp         = DateTime.strptime(yaml['tna_timestamp'].to_s, '%Y%m%d%H%M%S') #20120816224015
          site.query_params          = yaml['options'] ? yaml['options'].sub(/^.*--query-string /, '') : ''
          site.global_type           = global_type
          site.global_new_url        = global_new_url
          site.global_redirect_append_path = global_redirect_append_path
          site.homepage              = yaml['homepage']
          site.homepage_title        = yaml['homepage_title']
          site.homepage_furl         = yaml['homepage_furl']
          site.managed_by_transition = managed_by_transition?

          site.save!
        end
        @site.extra_organisations = Organisation.where(whitehall_slug: extra_organisation_slugs)
      end

      def import_hosts!
        [yaml['host'], yaml['aliases']].flatten.compact.each do |name|
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
        managed_by_transition = (yaml_filename =~ /\/transition-sites\//)
        SiteYamlFile.new(YAML.load(File.read(yaml_filename)), managed_by_transition)
      end
    end
  end
end
