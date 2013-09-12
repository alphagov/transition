require 'htmlentities'

module Transition
  module Import
    class SiteYamlFile
      attr_accessor :yaml

      def initialize(filename)
        self.yaml = YAML.load_file(filename)
      end

      def import!
        site_abbr = yaml['site']
        org_abbr  = site_abbr.sub(/_.*$/, '')

        organisation = import_organisation(org_abbr)
        site         = import_site(organisation, site_abbr)

        import_hosts(site)
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

      def import_site(organisation, site_abbr)
        Site.find_or_initialize_by_abbr(site_abbr).tap do |site|
          site.organisation       = organisation
          site.tna_timestamp      = yaml['tna_timestamp']
          site.query_params       = yaml['options'] ? yaml['options'].sub(/^.*--query-string /, '') : ''
          site.global_http_status = global_http_status
          site.global_new_url     = global_new_url
          site.homepage           = yaml['homepage']
          site.save
        end
      end

      def import_organisation(org_abbr)
        Organisation.find_or_initialize_by_abbr(org_abbr).tap do |organisation|
          organisation.update_attributes(
            {
              title:       HTMLEntities.new.decode(yaml['title']),
              launch_date: yaml['redirection_date'],
              homepage:    yaml['homepage'],
              furl:        yaml['furl'],
              css:         yaml['css'] || nil
            }
          )
        end
      end

      def import_hosts(site)
        [yaml['host'], yaml['aliases']].flatten.each do |name|
          if name
            host      = Host.find_or_initialize_by_hostname(name)
            host.site = site
            host.save
          end
        end
      end
    end
  end
end
