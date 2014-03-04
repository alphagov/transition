require 'optic14n'
require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class HitsMappingsRelations
      extend Transition::Import::ConsoleJobWrapper

      ##
      # Sloppy GROUP BY - path is not subject to aggregate. Note well,
      # Postgres upgraders
      REFRESH_HOST_PATHS = <<-mySQL
        INSERT IGNORE INTO host_paths(host_id, path_hash, path)
        SELECT hits.host_id, hits.path_hash, path
        FROM   hits
        GROUP  BY hits.host_id,
                  hits.path_hash
      mySQL

      REFRESH_HITS_FROM_HOST_PATHS = <<-mySQL
        UPDATE hits USE INDEX (index_hits_on_host_id_and_path_hash)
               INNER JOIN host_paths
                       ON host_paths.host_id = hits.host_id
                          AND host_paths.path_hash = hits.path_hash
        SET    hits.mapping_id = host_paths.mapping_id
      mySQL

      ##
      # A three-step refresh:
      #
      # 1. Refresh host_paths with INSERT IGNORE
      # 2. Fill in the host_paths.mapping_id for all rows where missing
      #    (using find_each, default batch size of 1000)
      # 3. Update hits with the mapping_id from host_paths
      def self.refresh!
        start 'Refreshing host paths' do
          ActiveRecord::Base.connection.execute(REFRESH_HOST_PATHS)
        end

        start 'Adding missing mapping_id/c14n_path_hash to host paths' do
          HostPath.where(mapping_id: nil).includes(:host).find_each do |host_path|
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

        start 'Updating hits from host paths' do
          ActiveRecord::Base.connection.execute(REFRESH_HITS_FROM_HOST_PATHS)
        end
      end

    end
  end
end
