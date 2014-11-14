require 'transition/import/console_job_wrapper'

module Transition
  module Import
    module MaterializedViews
      class Hits
        extend Transition::Import::ConsoleJobWrapper

        def self.all_hits_all_time(site)
          <<-postgreSQL
            SELECT
              hits.path, sum(hits.count) as count, hits.http_status,
              MIN(hits.mapping_id) AS mapping_id, MIN(hits.host_id) AS host_id
            FROM "hits"
            INNER JOIN "hosts" ON "hits"."host_id" = "hosts"."id"
            WHERE "hosts"."site_id" = #{site.id}
            GROUP BY path, http_status
            ORDER BY count DESC;
          postgreSQL
        end

        def self.refresh!
          Site.where(precompute_all_hits_view: true).each do |site|
            view_name = "#{site.abbr}_all_hits"

            if Postgres::MaterializedView.exist?(view_name)
              console_puts "Refreshing #{view_name}"
              Postgres::MaterializedView.refresh(view_name)
            else
              console_puts "Creating #{view_name}"
              Postgres::MaterializedView.create(view_name, all_hits_all_time(site))
            end
          end
        end
      end
    end
  end
end
