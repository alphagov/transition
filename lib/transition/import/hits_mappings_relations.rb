require 'optic14n'
require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class HitsMappingsRelations
      extend Transition::Import::ConsoleJobWrapper

      ##
      # A three-step refresh:
      #
      # 1. Refresh host_paths with INSERT IGNORE
      # 2. Fill in the host_paths.mapping_id for all rows where missing
      #    (using find_each, default batch size of 1000)
      # 3. Update hits with the mapping_id from host_paths
      def self.refresh!(site = nil)
        start 'Refreshing host paths' do
          refresh_host_paths(site)
        end

        start 'Adding missing mapping_id/c14n_path_hash to host paths' do
          connect_mappings_to_host_paths(site)
        end

        start 'Updating hits from host paths' do
          refresh_hits_from_host_paths(site)
        end
      end

    private
      def self.refresh_host_paths(site)
        site_scope = if site.present?
          host_ids = site.hosts.pluck(:id)
          "WHERE host_id in (#{host_ids.join(',')})"
        else
          ''
        end
        ##
        # Sloppy GROUP BY - path is not subject to aggregate. Note well,
        # Postgres upgraders
        sql = <<-mySQL
          INSERT IGNORE INTO host_paths(host_id, path_hash, path)
          SELECT hits.host_id, hits.path_hash, path
          FROM   hits
          #{site_scope}
          GROUP  BY hits.host_id,
                    hits.path_hash
        mySQL
        ActiveRecord::Base.connection.execute(sql)
      end

      def self.connect_mappings_to_host_paths(site)
        if site.present?
          host_paths = site.host_paths.where(mapping_id: nil)
        else
          host_paths = HostPath.where(mapping_id: nil)
        end

        host_paths.includes(:host).find_each do |host_path|
          site = host_path.host.site

          c14nized_path_hash =
            Digest::SHA1.hexdigest(site.canonical_path(host_path.path))
          mapping_id = Mapping.where(
            path_hash: c14nized_path_hash, site_id: site.id).pluck(:id).first

          if host_path.mapping_id != mapping_id || host_path.c14n_path_hash != c14nized_path_hash
            host_path.update_columns(
              mapping_id: mapping_id,
              c14n_path_hash: c14nized_path_hash)
          end
        end
      end

      def self.refresh_hits_from_host_paths(site)
        scope_to_site = if site.present?
          host_ids = site.hosts.pluck(:id)
          "AND host_paths.host_id in (#{host_ids.join(',')})"
        else
          ''
        end

        sql = <<-mySQL
          UPDATE hits USE INDEX (index_hits_on_host_id_and_path_hash)
                 INNER JOIN host_paths
                         ON host_paths.host_id = hits.host_id
                            AND host_paths.path_hash = hits.path_hash
                            #{scope_to_site}
          SET    hits.mapping_id = host_paths.mapping_id
        mySQL
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end
