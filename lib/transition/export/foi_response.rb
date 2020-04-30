require "transition/import/console_job_wrapper"

module Transition
  module Export
    class FOIResponse
      extend Transition::Import::ConsoleJobWrapper

      EXPORT_SITES = <<-POSTGRESQL.freeze
        COPY (
          SELECT
            abbr AS "Abbreviation",
            launch_date AS "Launch Date",
            homepage AS "New Homepage",
            to_char(tna_timestamp, 'YYYYMMDDHH24MISS') AS "TNA Timestamp",
            query_params AS "Significant querystring parameters (colon separated)",
            CASE global_type WHEN 'unresolved' THEN 410 WHEN 'archive' THEN 410 WHEN 'redirect' THEN 301 END AS "Global HTTP status",
            global_new_url AS "New URL for global 301",
            CASE global_redirect_append_path WHEN 'f' THEN 'false' WHEN 't' THEN 'true' END AS "Append requested path to new URL? (for global 301)"
            FROM sites
            ORDER BY abbr
        ) TO STDOUT WITH DELIMITER ',' CSV HEADER;
      POSTGRESQL

      EXPORT_HOSTS = <<-POSTGRESQL.freeze
        COPY (
        SELECT
          sites.abbr AS "Site abbreviation",
          hostname
          FROM hosts
          INNER JOIN sites ON hosts.site_id = sites.id
          WHERE canonical_host_id IS NULL
          ORDER BY sites.abbr, hostname
        ) TO STDOUT WITH DELIMITER ',' CSV HEADER;
      POSTGRESQL

      EXPORT_MAPPINGS = <<-POSTGRESQL.freeze
        COPY (
          SELECT
            sites.abbr AS "Site abbreviation",
            path AS "Old Path",
            CASE type WHEN 'unresolved' THEN 410 WHEN 'archive' THEN 410 WHEN 'redirect' THEN 301 END AS "HTTP status",
            new_url AS "Redirect URL",
            archive_url AS "Custom Archive URL",
            suggested_url AS "Suggested URL"
            FROM mappings
            INNER JOIN sites ON mappings.site_id = sites.id
            WHERE sites.global_type IS NULL
            ORDER BY sites.abbr, path
        ) TO STDOUT WITH DELIMITER ',' CSV HEADER;
      POSTGRESQL

      def self.export!
        timestamp = Time.zone.now.iso8601
        export_data(timestamp, "sites", EXPORT_SITES)
        export_data(timestamp, "hosts", EXPORT_HOSTS)
        export_data(timestamp, "mappings", EXPORT_MAPPINGS)
      end

      def self.export_data(timestamp, table, sql)
        start "Exporting #{table}" do |_job|
          File.open("tmp/#{table}-#{timestamp}.csv", "w") do |f|
            ActiveRecord::Base.connection.raw_connection.tap do |raw_conn|
              raw_conn.copy_data(sql) do
                while (row = raw_conn.get_copy_data)
                  f.write(row.force_encoding("UTF-8"))
                end
              end
            end
          end
        end
      end
    end
  end
end
