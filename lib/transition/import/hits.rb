require 'pathname'
require 'transition/import/console_job_wrapper'
require 'transition/import/postgresql_settings'
require 'transition/import/hits/ignore'

module Transition
  module Import
    class Hits
      extend ConsoleJobWrapper
      extend PostgreSQLSettings

      TRUNCATE = <<-POSTGRESQL.freeze
        TRUNCATE hits_staging
      POSTGRESQL

      LOAD_CSV_DATA = <<-POSTGRESQL.freeze
        COPY hits_staging (hit_on, count, http_status, hostname, path)
        FROM STDIN
        WITH CSV HEADER
      POSTGRESQL

      LOAD_TSV_DATA = <<-POSTGRESQL.freeze
        COPY hits_staging (hit_on, count, http_status, hostname, path)
        FROM STDIN
        WITH DELIMITER AS E'\t' QUOTE AS E'\b' CSV HEADER
      POSTGRESQL

      INSERT_FROM_STAGING = <<-POSTGRESQL.freeze
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
      POSTGRESQL

      UPDATE_FROM_STAGING = <<-POSTGRESQL.freeze
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
      POSTGRESQL

      def self.find_import_record(filename)
        ImportedHitsFile.where(filename: filename).first_or_initialize
      end

      def self.from_stream!(load_data_query, import_record, content_hash, stream)
        Hit.transaction do
          import_record.content_hash = content_hash

          ActiveRecord::Base.connection.execute(TRUNCATE)
          ActiveRecord::Base.connection.raw_connection.tap do |raw|
            raw.copy_data(load_data_query) do
              raw.put_copy_data(stream)
            end
          end
          ActiveRecord::Base.connection.execute(INSERT_FROM_STAGING)
          ActiveRecord::Base.connection.execute(UPDATE_FROM_STAGING)

          import_record.save!
        end
      end

      def self.from_s3!(bucket)
        Services.s3.list_objects(bucket: bucket).each do |resp|
          resp.contents.each do |object|
            start "Importing #{object.key}" do |job|
              job.skip! and next if object.key.end_with? '.csv.metadata'

              import_record = self.find_import_record(object.key)
              job.skip! and next if import_record.content_hash == object.etag

              is_tsv = object.key.end_with? '.tsv'
              load_data_query = is_tsv ? LOAD_TSV_DATA : LOAD_CSV_DATA

              resp = Services.s3.get_object(bucket: bucket, key: object.key)
              self.from_stream!(
                load_data_query,
                import_record,
                object.etag,
                resp.body.read,
              )
            end
          end
        end
      end

      def self.from_file!(load_data_query, filename)
        start "Importing #{filename}" do |job|
          absolute_filename = File.expand_path(filename, Rails.root)
          relative_filename = Pathname.new(absolute_filename).relative_path_from(Rails.root).to_s
          content_hash = Digest::SHA1.hexdigest(File.read(relative_filename))

          import_record = self.find_import_record(relative_filename)
          job.skip! and next if import_record.content_hash == content_hash

          self.from_stream!(
            load_data_query,
            import_record,
            content_hash,
            File.open(absolute_filename, 'r').read,
          )
        end
      end

      def self.from_tsv!(filename)
        self.from_file!(LOAD_TSV_DATA, filename)
      end

      def self.from_csv!(filename)
        self.from_file!(LOAD_CSV_DATA, filename)
      end

      def self.from_mask!(filemask)
        done = 0
        unchanged = 0

        change_settings('work_mem' => '2GB') do
          Dir[File.expand_path(filemask)].each do |filename|
            is_tsv = File.extname(filename) == '.tsv'
            load_data_query = is_tsv ? LOAD_TSV_DATA : LOAD_CSV_DATA

            Hits.from_file!(load_data_query, filename) ? done += 1 : unchanged += 1
          end

          console_puts "#{done} hits #{'file'.pluralize(done)} imported (#{unchanged} unchanged)."
        end

        done
      end
    end
  end
end
