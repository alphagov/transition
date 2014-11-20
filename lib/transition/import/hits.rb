require 'pathname'
require 'transition/import/console_job_wrapper'
require 'transition/import/postgresql_settings'
require 'transition/import/hits/ignore'

module Transition
  module Import
    class Hits
      extend ConsoleJobWrapper
      extend PostgreSQLSettings

      TRUNCATE = <<-postgreSQL
        TRUNCATE hits_staging
      postgreSQL

      LOAD_DATA = <<-postgreSQL
        COPY hits_staging (hit_on, count, http_status, hostname, path)
        FROM STDIN
        WITH DELIMITER AS E'\t' QUOTE AS E'\b' CSV HEADER
      postgreSQL

      INSERT_FROM_STAGING = <<-postgreSQL
        INSERT INTO hits (host_id, path, http_status, count, hit_on)
        SELECT h.id, st.path, st.http_status, st.count, st.hit_on
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        WHERE LENGTH(st.path) <= 2048
          AND st.path NOT IN (#{ Ignore::PATHS.map { |path| "'" + path + "'" }.join(', ') })
          AND st.path !~ '#{ Ignore::PATTERNS.join('|') }'
          AND NOT EXISTS (
            SELECT 1 FROM hits
            WHERE path        = st.path AND
                  host_id     = h.id AND
                  http_status = st.http_status AND
                  hit_on      = st.hit_on
          );
      postgreSQL

      UPDATE_FROM_STAGING = <<-postgreSQL
        UPDATE hits
        SET count = st.count
        FROM hits_staging st
        INNER JOIN hosts ON hosts.hostname = st.hostname
        WHERE
          hits.path        = st.path AND
          hits.http_status = st.http_status AND
          hits.hit_on      = st.hit_on AND
          hits.host_id     = hosts.id AND
          hits.count       IS DISTINCT FROM st.count
      postgreSQL

      def self.copy_to_hits_staging(filename)
        ActiveRecord::Base.connection.raw_connection.tap do |raw|
          raw.copy_data(LOAD_DATA) do
            raw.put_copy_data(File.open(filename, 'r').read)
          end
        end
      end

      def self.from_tsv!(filename)
        start "Importing #{filename}" do |job|
          absolute_filename = File.expand_path(filename, Rails.root)
          relative_filename = Pathname.new(absolute_filename).relative_path_from(Rails.root).to_s

          Hit.transaction do
            import_record = ImportedHitsFile.where(
                filename: relative_filename).first_or_initialize

            job.skip! and next if import_record.same_on_disk?

            ActiveRecord::Base.connection.execute(TRUNCATE)
            copy_to_hits_staging(absolute_filename)
            ActiveRecord::Base.connection.execute(INSERT_FROM_STAGING)
            ActiveRecord::Base.connection.execute(UPDATE_FROM_STAGING)

            import_record.save!
          end
        end
      end

      def self.from_mask!(filemask)
        done, unchanged = 0, 0

        change_settings('work_mem' => '2GB') do
          Dir[File.expand_path(filemask)].each do |filename|
            Hits.from_tsv!(filename) ? done += 1 : unchanged += 1
          end

          console_puts "#{done} hits #{'file'.pluralize(done)} imported (#{unchanged} unchanged)."
        end

        done
      end
    end
  end
end
