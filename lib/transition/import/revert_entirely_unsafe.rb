require "transition/import/console_job_wrapper"

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
          destroy_all_versions

          destroy_all_mappings

          destroy_all_hosts

          @site.destroy!

          console_puts "Deleted site: #{@site.abbr}"
        end

        def destroy_all_versions
          console_puts "Removing versions for: #{@site.abbr}"
          @site.mappings.each do |map|
            map.versions.destroy_all
          end
        end

        def destroy_all_mappings
          console_puts "Removing mappings for: #{@site.abbr}"
          @site.mappings.destroy_all
        end

        def destroy_all_hosts
          @site.hosts.each do |host|
            destroy_all_hits(host)

            destroy_all_host_paths(host)
          end

          console_puts "Removing all hosts"
          @site.hosts.destroy_all
        end

        def destroy_all_hits(host)
          console_puts "Removing daily hits for host: #{host.hostname}"
          host.daily_hit_totals.destroy_all

          console_puts "Removing hits for host: #{host.hostname}"
          host.hits.destroy_all
        end

        def destroy_all_host_paths(host)
          console_puts "Removing host paths for host: #{host.hostname}"
          host.host_paths.destroy_all
        end
      end
    end
  end
end
