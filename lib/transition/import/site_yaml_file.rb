require 'htmlentities'

module Transition
  module Import
    ##
    # A transition-centric view over redirector yaml
    class SiteYamlFile < Struct.new(:yaml, :other_sites)
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

      attr_reader :site
      def import_site!
        @site = Site.where(abbr: abbr).first_or_initialize do |site|
          site.organisation          = Organisation.find_by_whitehall_slug(whitehall_slug)

          site.tna_timestamp         = yaml['tna_timestamp']
          site.query_params          = yaml['options'] ? yaml['options'].sub(/^.*--query-string /, '') : ''
          site.global_http_status    = global_http_status
          site.global_new_url        = global_new_url
          site.homepage              = yaml['homepage']
          site.managed_by_transition = false

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
    end
  end
end
