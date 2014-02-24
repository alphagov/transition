require 'optic14n'

module Transition
  module Import
    class HitsMappingsRelations
      ##
      #
      # Simulation of FIRST via GROUP_CONCAT
      # http://stackoverflow.com/questions/13957082/selecting-first-and-last-values-in-a-group
      # USE INDEX hint also necessary to avoid query running till heat
      # death of universe (it'll still take a couple of minutes).
      #
      # mySQL, you need to stop hiding Smirnoff in the cornflakes.
      #
      REFRESH_HOST_PATHS = <<-mySQL
        INSERT IGNORE INTO host_paths(host_id, path_hash, path)
        SELECT hits.host_id,
               hits.path_hash,
               SUBSTRING_INDEX(GROUP_CONCAT(CAST(path AS CHAR)), ',', 1) # Simulate FIRST()
               AS path
        FROM   hits USE INDEX (index_hits_on_host_id_and_path_hash_and_hit_on_and_http_status)
               INNER JOIN hosts ON hosts.id = hits.host_id
               INNER JOIN sites ON sites.id = hosts.site_id
        GROUP  BY hits.host_id,
                  hits.path_hash
      mySQL

      REFRESH_HITS_FROM_HOST_PATHS = <<-mySQL
        UPDATE hits
        INNER JOIN host_paths ON
          host_paths.host_id = hits.host_id AND host_paths.path_hash = hits.path_hash
        SET hits.mapping_id = host_paths.mapping_id
        WHERE
          host_paths.mapping_id IS NOT NULL
      mySQL

      ##
      # A three-step refresh:
      #
      # 1. Refresh host_paths with INSERT IGNORE
      # 2. Fill in the host_paths.mapping_id for all rows where missing
      #    (using find_each, default batch size of 1000)
      # 3. Update hits with the mapping_id from host_paths
      def self.refresh!
        Rails.logger.info 'Refreshing host paths...'
        ActiveRecord::Base.connection.execute(REFRESH_HOST_PATHS)

        Rails.logger.info 'Adding missing mapping_id/c14n_path_hash to host paths...'
        HostPath.where(mapping_id: nil).includes(:host).find_each do |host_path|
          site = host_path.host.site

          c14nized_path_hash =
            Digest::SHA1.hexdigest(site.canonical_path(host_path.path))
          mapping_id = Mapping.where(
            path_hash: c14nized_path_hash, site_id: site.id).pluck(:id).first
          host_path.update_columns(
            mapping_id: mapping_id,
            c14n_path_hash: c14nized_path_hash) if mapping_id && (host_path.mapping_id != mapping_id)
        end

        Rails.logger.info 'Updating hits from host paths...'
        ActiveRecord::Base.connection.execute(REFRESH_HITS_FROM_HOST_PATHS)
      end

    end
  end
end
