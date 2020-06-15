require "optic14n"
require "transition/import/console_job_wrapper"
require "transition/import/postgresql_settings"

module Transition
  module Import
    class HitsMappingsRelations
      include Transition::Import::ConsoleJobWrapper
      include Transition::Import::PostgreSQLSettings

      attr_accessor :site
      def initialize(site = nil)
        self.site = site
      end

      def refresh!
        start("Refreshing host paths") { refresh_host_paths! }
        start("Adding missing mapping_id/canonical_path to host paths") { connect_mappings_to_host_paths! }
        start("Updating hits from host paths") { refresh_hits_from_host_paths! }
        start("Precomputing mapping hit counts") { precompute_mapping_hit_counts! }
      end

      def self.refresh!(site = nil)
        HitsMappingsRelations.new(site).refresh!
      end

    private

      def in_site_hosts
        host_ids = site.reload.hosts.pluck(:id)
        " IN (#{host_ids.join(',')})"
      end

      def host_paths
        if site
          site.host_paths.where(mapping_id: nil)
        else
          HostPath.where(mapping_id: nil)
        end
      end

      def refresh_host_paths!
        and_host_is_in_site = site ? "AND hits.host_id #{in_site_hosts}" : ""
        sql = <<-POSTGRESQL
          INSERT INTO host_paths(host_id, path)
          SELECT hits.host_id, hits.path
          FROM   hits
          WHERE NOT EXISTS (
            SELECT 1 FROM host_paths
            WHERE
              host_paths.host_id   = hits.host_id AND
              host_paths.path      = hits.path
          )
          #{and_host_is_in_site}
          GROUP  BY hits.host_id,
                    hits.path
        POSTGRESQL
        change_settings("work_mem" => "256MB") do
          ActiveRecord::Base.connection.execute(sql)
        end
      end

      def connect_mappings_to_host_paths!
        host_paths.includes(:host).find_each do |host_path|
          site = host_path.host&.site

          unless site
            warn "#{host_path} not associated with a site"
            next
          end

          canonical_path = site.canonical_path(host_path.path)
          mapping_id = Mapping.where(
            path: canonical_path, site_id: site.id,
          ).pick(:id)

          if host_path.mapping_id != mapping_id || host_path.canonical_path != canonical_path
            host_path.update_columns(
              mapping_id: mapping_id,
              canonical_path: canonical_path,
            )
          end
        end
      end

      def refresh_hits_from_host_paths!
        and_host_is_in_site = site ? "AND host_paths.host_id #{in_site_hosts}" : ""

        # IS DISTINCT FROM is effectively <> - see
        # https://gist.github.com/rgarner/7cccbc504de7c8d56702
        sql = <<-POSTGRESQL
          UPDATE hits
          SET  mapping_id = host_paths.mapping_id
          FROM host_paths
          WHERE
            host_paths.host_id   = hits.host_id AND
            host_paths.path      = hits.path AND
            host_paths.mapping_id IS DISTINCT FROM hits.mapping_id
            #{and_host_is_in_site}
        POSTGRESQL
        ActiveRecord::Base.connection.execute(sql)
      end

      def precompute_mapping_hit_counts!
        where_host_is_in_site = site ? "WHERE host_id #{in_site_hosts}" : ""
        sql = <<-POSTGRESQL
          UPDATE mappings
          SET hit_count = with_counts.hit_count
          FROM (
            SELECT hits.mapping_id, SUM(hits.count) AS hit_count
            FROM hits
            #{where_host_is_in_site}
            GROUP BY hits.mapping_id
          ) with_counts
          WHERE
            mappings.id = with_counts.mapping_id AND
            mappings.hit_count IS DISTINCT FROM with_counts.hit_count
        POSTGRESQL

        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end
