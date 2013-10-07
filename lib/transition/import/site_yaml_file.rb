require 'htmlentities'

module Transition
  module Import
    ##
    # A transition-centric view over redirector yaml
    # to infer parent and org
    class SiteYamlFile < Struct.new(:yaml, :other_sites)
      def import!
        import_site!
        import_hosts!
      end

      def abbr
        yaml['site']
      end

      def title
        HTMLEntities.new.decode(yaml['title'])
      end

      %w(furl redirection_date homepage css).each do |name|
        define_method name.to_sym do
          yaml[name]
        end
      end

      def inferred_organisation
        abbr.split('_').last
      end

      def inferred_parent
        abbr.split('_').first if child? # nil otherwise
      end

      ##
      # A Site is an organisation from the point of view of Transition either
      # when it has no parent or its title is different from that of its parent department
      def organisation?
        parent_org_site = other_sites.departments[inferred_parent]
        parent_org_site.nil? || (parent_org_site.title != title)
      end

      def child?
        abbr.include?('_')
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
        @site = Site.find_or_initialize_by_abbr(abbr).tap do |site|
          site.organisation       = child? ? Organisation.find_by_abbr(inferred_parent) : Organisation.find_by_abbr(inferred_organisation)
          site.tna_timestamp      = yaml['tna_timestamp']
          site.query_params       = yaml['options'] ? yaml['options'].sub(/^.*--query-string /, '') : ''
          site.global_http_status = global_http_status
          site.global_new_url     = global_new_url
          site.homepage           = yaml['homepage']
          site.save!
        end
      end

      def import_hosts!
        [yaml['host'], yaml['aliases']].flatten.each do |name|
          if name
            host      = Host.find_or_initialize_by_hostname(name)
            host.site = site
            host.save!
          end
        end
      end
    end
  end
end
