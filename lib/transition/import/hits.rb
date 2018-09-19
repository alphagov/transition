require 'pathname'
require 'transition/import/console_job_wrapper'
require 'transition/import/postgresql_settings'
require 'transition/import/hits/ignore'

module Transition
  module Import
    class Hits
      extend ConsoleJobWrapper
      extend PostgreSQLSettings

      TRUNCATE = <<-postgreSQL.freeze
        TRUNCATE hits_staging
      postgreSQL

      LOAD_DATA = <<-postgreSQL.freeze
        COPY hits_staging (hit_on, count, http_status, hostname, path)
        FROM STDIN
        WITH DELIMITER AS E'\t' QUOTE AS E'\b' CSV HEADER
      postgreSQL

      INSERT_FROM_STAGING = <<-postgreSQL.freeze
        INSERT INTO hits (host_id, path, http_status, count, hit_on)
        SELECT h.id, st.path, st.http_status, st.count, st.hit_on
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        WHERE LENGTH(st.path) <= 2048
          AND st.path NOT IN (#{Ignore::PATHS.map { |path| "'" + path + "'" }.join(', ')})
          AND st.path !~ '#{Ignore::PATTERNS.join('|')}'
          AND NOT EXISTS (
            SELECT 1 FROM hits
            WHERE path        = st.path AND
                  host_id     = h.id AND
                  http_status = st.http_status AND
                  hit_on      = st.hit_on
          );
      postgreSQL

      UPDATE_FROM_STAGING = <<-postgreSQL.freeze
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

      def self.from_tsv_stream!(filename, content_hash, stream)
        start "Importing #{filename}" do |job|
          Hit.transaction do
            import_record = ImportedHitsFile
                              .where(filename: filename)
                              .first_or_initialize

            job.skip! and next if import_record.content_hash == content_hash
            import_record.content_hash = content_hash

            ActiveRecord::Base.connection.execute(TRUNCATE)
            ActiveRecord::Base.connection.raw_connection.tap do |raw|
              raw.copy_data(LOAD_DATA) do
                raw.put_copy_data(stream)
              end
            end
            ActiveRecord::Base.connection.execute(INSERT_FROM_STAGING)
            ActiveRecord::Base.connection.execute(UPDATE_FROM_STAGING)

            import_record.save!
          end
        end
      end

      def self.from_tsv!(filename)
        absolute_filename = File.expand_path(filename, Rails.root)
        relative_filename = Pathname.new(absolute_filename).relative_path_from(Rails.root).to_s
        content_hash = Digest::SHA1.hexdigest(File.read(relative_filename))

        self.from_tsv_stream!(
          relative_filename,
          content_hash,
          File.open(absolute_filename, 'r').read,
        )
      end

      def self.from_mask!(filemask)
        done = 0
        unchanged = 0

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
