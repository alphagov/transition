require "transition/import/console_job_wrapper"

module Transition
  module Import
    module Revert
      ##
      # Reverts the import of sites, if they have no mappings or hits - ie no
      # associated data beyond that which was created by importing the site
      # YAML file
      class Sites
        include Transition::Import::ConsoleJobWrapper

        def initialize(site_abbrs)
          @site_abbrs = site_abbrs
        end

        def revert_all!
          console_puts "Trying to delete sites: #{@site_abbrs.join(', ')}"

          @site_abbrs.each { |abbr| revert_safely!(abbr) }

          console_puts "Ensure that the deleted sites have also been deleted from the transition-config repo; otherwise they will be re-imported."
        end

      private

        def revert_safely!(abbr)
          Site.transaction do
            site = Site.find_by(abbr: abbr)
            unless site
              console_puts "Site #{abbr} doesn't exist; skipping"
              return
            end

            mappings_count = site.mappings.count
            hits_count = site.hits.count
            # checking hits also accounts for host_paths and daily_hit_totals
            if mappings_count.zero? && hits_count.zero?
              destroy_site_and_associations(site)
              console_puts "Deleted site #{abbr}"
            else
              console_puts "Site #{abbr} has #{mappings_count} mappings and #{hits_count} hits; not deleting"
            end
          end
        end

        def destroy_site_and_associations(site)
          # We can ignore mappings batches - they're cleaned up overnight
          site.hosts.each(&:destroy)
          site.destroy! # this also deletes the organisations_sites row
        end
      end
    end
  end
end
