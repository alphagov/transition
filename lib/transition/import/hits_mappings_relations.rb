require 'optic14n'
require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class HitsMappingsRelations
      include Transition::Import::ConsoleJobWrapper

      attr_accessor :site
      def initialize(site = nil)
        self.site = site
      end

      def refresh!
        #
        # A three-step refresh:
        #
        # 1. Refresh host_paths with INSERT IGNORE
        # 2. Fill in the host_paths.mapping_id for all rows where missing
        #    (using find_each, default batch size of 1000)
        # 3. Update hits with the mapping_id from host_paths
        #
        {
          'Refreshing host paths' => :refresh_host_paths!,
          'Adding missing mapping_id/c14n_path_hash to host paths' => :connect_mappings_to_host_paths!,
          'Updating hits from host paths' => :refresh_hits_from_host_paths!
        }.each_pair do |msg, step|
          start(msg) { send step }
        end
      end

      def self.refresh!(site = nil)
        HitsMappingsRelations.new(site).refresh!
      end

    private
      def in_site_hosts
        host_ids = site.hosts.pluck(:id)
        " IN (#{host_ids.join(',')})"
      end

      def host_paths
        site.present? ?
          site.host_paths.where(mapping_id: nil) :
          HostPath.where(mapping_id: nil)
      end

      def refresh_host_paths!
        where_host_is_in_site = site ? "WHERE host_id #{in_site_hosts}" : ''

        #
        # Sloppy GROUP BY - path is not subject to aggregate. Note well,
        # Postgres upgraders
        sql = <<-mySQL
          INSERT IGNORE INTO host_paths(host_id, path_hash, path)
          SELECT hits.host_id, hits.path_hash, path
          FROM   hits
          #{where_host_is_in_site}
          GROUP  BY hits.host_id,
                    hits.path_hash
        mySQL
        ActiveRecord::Base.connection.execute(sql)
      end

      def connect_mappings_to_host_paths!
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

      def refresh_hits_from_host_paths!
        and_host_is_in_site = site ? "AND host_paths.host_id #{in_site_hosts}" : ''

        sql = <<-mySQL
          UPDATE hits USE INDEX (index_hits_on_host_id_and_path_hash)
                 INNER JOIN host_paths
                         ON host_paths.host_id = hits.host_id
                            AND host_paths.path_hash = hits.path_hash
                            #{and_host_is_in_site}
          SET    hits.mapping_id = host_paths.mapping_id
        mySQL
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end
