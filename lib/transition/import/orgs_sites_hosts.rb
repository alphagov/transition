require 'transition/import/site_yaml_file'

module Transition
  module Import
    class OrgsSitesHosts
      class NoYamlFound < RuntimeError; end

      def initialize(yaml_mask)
        @yaml_files = Dir.glob(yaml_mask)
        raise NoYamlFound if @yaml_files.empty?
      end

      def self.from_redirector_yaml!(mask)
        OrgsSitesHosts.new(mask).import!
      end

      def import!
        import_inferred_orgs!
        import_sites!
      end

      def import_inferred_orgs!
        organisations.values.map do |site|
          Organisation.find_or_create_by_abbr!(site.inferred_organisation) do |org|
            org.launch_date = site.redirection_date
            %w(abbr title furl homepage css).each do |meth|
              getter, setter = meth.to_sym, "#{meth}=".to_sym
              org.send setter, site.send(getter)
            end
          end
        end
      end

      def import_sites!
        sites.values.each { |s| s.import! }
      end

      ##
      # All sites
      def sites
        @sites ||= load_sites
      end

      def load_sites
        {}.tap do |sites_hash|
          @yaml_files.each do |filename|
            site_yaml                     = YAML::load(File.read(filename))
            sites_hash[site_yaml['site']] = SiteYamlFile.new(site_yaml, self)
          end
        end
      end

      ##
      # Only departmental sites (no '_' in the site abbreviation)
      # (in other words, sites that are eligible to be parents)
      def departments
        sites.select { |_, site| !site.child? }
      end

      ##
      # All orgs (things that are not *just* sites)
      def organisations
        sites.select { |_, site| site.organisation? }
      end
    end
  end
end
