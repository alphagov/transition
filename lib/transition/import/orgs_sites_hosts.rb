require 'transition/import/site_yaml_file'
require 'transition/import/whitehall_orgs'

module Transition
  module Import
    class OrgsSitesHosts
      class NoYamlFound < RuntimeError; end

      def initialize(yaml_mask)
        @yaml_files = Dir.glob(yaml_mask)
        raise NoYamlFound if @yaml_files.empty?
      end

      def self.from_redirector_yaml!(mask)
        OrgsSitesHosts.new(mask).tap do |orgs_sites_hosts|
          yield orgs_sites_hosts if block_given?
          orgs_sites_hosts.import!
        end
      end

      def import!
        import_inferred_orgs!
        import_sites!
      end

      def import_inferred_orgs!
        # Two passes, one to set up organisations
        # and one to set up their parents.
        Organisation.transaction do
          organisations.values.each do |site|
            create_org_from(site)
          end
          organisations.values.select { |s| s.child? }.each do |site|
            Organisation.find_by_redirector_abbr!(site.inferred_organisation).tap do |org|
              inferred_parent_org = Organisation.find_by_redirector_abbr!(site.inferred_parent)
              unless org.parent_organisations.include?(inferred_parent_org)
                org.parent_organisations << inferred_parent_org
              end
            end
          end
        end
      end

      def create_org_from(site)
        Organisation.where(redirector_abbr: site.inferred_organisation).first_or_create.tap do |org|
          %w(title furl homepage css).each { |attr| org.send "#{attr}=".to_sym, site.send(attr.to_sym) }

          org.redirector_abbr = site.inferred_organisation

          if (whitehall_org = whitehall_organisations.by_title[org.title])
            org.abbreviation   = whitehall_org.details.abbreviation
            org.whitehall_type = whitehall_org.format
            org.whitehall_slug = whitehall_org.details.slug
          end
          org.save!
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

      def whitehall_organisations
        @organisations ||= WhitehallOrgs.new
      end
    end
  end
end
