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
          console_puts "Trying to delete site and all associated data: #{@site.default_host.hostname}"

          destroy_site_data
        end

      private

        def destroy_site_data
          destroy_all_versions

          destroy_all_mappings

          destroy_all_hosts

          @site.destroy!

          console_puts "Deleted site: #{@site.default_host.hostname}"
        end

        def destroy_all_versions
          console_puts "Removing versions for: #{@site.default_host.hostname}"
          @site.mappings.each do |map|
            map.versions.destroy_all
          end
        end

        def destroy_all_mappings
          console_puts "Removing mappings for: #{@site.default_host.hostname}"
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
