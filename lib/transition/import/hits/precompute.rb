require "transition/import/console_job_wrapper"

module Transition
  module Import
    class Hits
      class Precompute
        include Transition::Import::ConsoleJobWrapper

        def initialize(site_ids, new_precompute_value)
          @site_ids = site_ids.reject(&:blank?)
          @new_precompute_value = new_precompute_value
        end

        def update!
          @updated = 0

          Site.transaction do
            sites.each do |site|
              if site.precompute_all_hits_view == @new_precompute_value
                console_puts "WARN: skipping site with ID '#{site.id}' - already set to #{@new_precompute_value}"
              else
                start "Setting #{site.id} precompute_all_hits_view to #{@new_precompute_value}" do
                  site.update!(precompute_all_hits_view: @new_precompute_value)
                  @updated += 1
                end
              end
            end
          end

          inform_about_refresh if display_refresh_info?
          @updated
        end

      private

        def sites
          @site_ids.map { |id| Site.find(id) }.compact
        end

        def inform_about_refresh
          console_puts <<~TEXT
            \nIf you want to feel the benefit immediately, you should now run

              rake import:hits:refresh_materialized\n
          TEXT
        end

        def display_refresh_info?
          @new_precompute_value && @updated.positive?
        end
      end
    end
  end
end
