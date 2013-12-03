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

      def whitehall_slug
        yaml['whitehall_slug'] || case abbr
                                    when /^directgov.*/ then 'directgov'
                                    when /^businesslink.*/ then 'business-link'
                                  end
      end

      def title
        HTMLEntities.new.decode(yaml['title'])
      end

      %w(furl redirection_date homepage css).each do |name|
        define_method name.to_sym do
          yaml[name]
        end
      end

      def has_global_status?
        # cdn.hm-treasury.gov.uk has a regex in the global value, which Bouncer
        # implements as a "rule", so we can ignore it.
        yaml['global'] && (yaml['host'] != 'cdn.hm-treasury.gov.uk')
      end

      def global_http_status
        # There are two expected formats of the 'global' value:
        # global: =301 https://secure.fera.defra.gov.uk/nonnativespecies/beplantwise/
        #
        # or:
        # global: =410
        yaml['global'].split(' ')[0].gsub("=", "") if has_global_status?
      end

      def global_new_url
        yaml['global'].split(' ')[1] if has_global_status?
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
          site.tna_timestamp         = yaml['tna_timestamp']
          site.query_params          = yaml['options'] ? yaml['options'].sub(/^.*--query-string /, '') : ''
          site.global_http_status    = global_http_status
          site.global_new_url        = global_new_url
          site.homepage              = yaml['homepage']
          site.managed_by_transition = managed_by_transition?

          site.save!
        end
      end

      def import_hosts!
        [yaml['host'], yaml['aliases']].flatten.compact.each do |name|
          Host.where(hostname: name).first_or_create do |host|
            host.site = site
            host.save!
          end
        end
      end

      def self.load(yaml_filename)
        managed_by_transition = (yaml_filename =~ /\/transition-sites\//)
        SiteYamlFile.new(YAML.load(File.read(yaml_filename)), managed_by_transition)
      end
    end
  end
end
