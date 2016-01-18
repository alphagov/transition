require 'transition/import/console_job_wrapper'

module Transition
  module Import
    module RevertEntirelyUnsafe
      ##
      # Reverts the import of a site and deletes all data associated with it
      class RevertSite
        include Transition::Import::ConsoleJobWrapper

        def initialize(site)
          @site = site
        end

        def revert_all_data!
          console_puts "Trying to delete site and all associated data: #{@site.abbr}"

          destroy_site_data

          console_puts "***Ensure that the deleted site has also been deleted from the transition-config repo otherwise it will be re-imported.*** \n***This has not removed anything from the hits directory.***"
        end

      private
        def destroy_site_data
          destroy_all_mappings

          destroy_all_hosts

          destroy_organisation

          @site.destroy

          console_puts "Deleted site: #{@site.abbr}"
        end

        def destroy_all_mappings
          console_puts "Removing mappings and versions for site: #{@site.abbr}"
          Mapping.where(site_id: @site.id).each do |map|
            destroy_all_versions(map)

            console_puts "Removing mapping: #{map.path}"
            map.destroy
          end
        end

        def destroy_all_versions(map)
          map.versions.each(&:destroy)
        end

        def destroy_all_hosts
          @site.hosts.each do |host|
            destroy_all_hits(host)

            destroy_all_host_paths(host)

            console_puts "Removing host: #{host.hostname}"
            host.destroy
          end
        end

        def destroy_all_hits(host)
          console_puts "Removing daily hits for host: #{host.hostname}"
          DailyHitTotal.where(host_id: host.id).each(&:destroy)

          console_puts "Removing hits for host: #{host.hostname}"
          Hit.where(host_id: host.id).each(&:destroy)
        end

        def destroy_all_host_paths(host)
          console_puts "Removing host paths for host: #{host.hostname}"
          HostPath.where(host_id: host.id).each(&:destroy)
        end

        def destroy_organisation
          destroy_organisational_relationships

          destroy_organisations_sites

          console_puts "Removing organisation: #{@site.homepage}"
          Organisation.where(id: @site.organisation_id).destroy_all
        end

        def destroy_organisational_relationships
          console_puts "Removing organisational relationships for site: #{@site.abbr}"
          OrganisationalRelationship
            .where(child_organisation_id: @site.organisation_id)
            .each(&:destroy)
        end

        def destroy_organisations_sites
          console_puts "Removing organisations sites: #{@site.abbr}"

          delete = "DELETE FROM organisations_sites WHERE"
          by_site_id = "site_id = #{@site.id}"
          by_org_id = "organisation_id = #{@site.organisation_id}"

          ActiveRecord::Base.connection.execute("#{delete} #{by_site_id}")

          ActiveRecord::Base.connection.execute("#{delete} #{by_org_id}")
        end

      end
    end
  end
end
