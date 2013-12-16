module Transition
  module Import
    class Mappings
      TRUNCATE = <<-mySQL
        TRUNCATE mappings_staging
      mySQL

      LOAD_DATA = <<-mySQL
        LOAD DATA LOCAL INFILE $filename$
        INTO TABLE
          mappings_staging
        FIELDS TERMINATED BY ','
        LINES TERMINATED BY '\\n'
        IGNORE 1 LINES
          (@old_url, new_url, http_status, suggested_url, archive_url)
        SET
          host = TRIM(LEADING 'http://' FROM SUBSTRING_INDEX(@old_url, '/', 3)), /* Everything up to the 3rd slash or end of string */
          path = replace(@old_url, SUBSTRING_INDEX(@old_url, '/', 3), ''),       /* wow, this is ugly */
          path_hash = SHA1(path),
          old_url = @old_url
      mySQL

      INSERT_FROM_STAGING = <<-mySQL
        INSERT INTO mappings (site_id, path, path_hash, http_status, new_url, suggested_url, archive_url, from_redirector)
        SELECT h.site_id, st.path, st.path_hash, st.http_status, st.new_url, st.suggested_url, st.archive_url, true
        FROM
          mappings_staging st
        INNER JOIN hosts h on h.hostname = st.host
        ON DUPLICATE KEY UPDATE http_status = st.http_status, new_url = st.new_url,
                                suggested_url = st.suggested_url, archive_url = st.archive_url
      mySQL

      def self.from_redirector_csv_file!(filename)
        if managed_by_transition?(filename)
          $stderr.puts "skipped #{filename} because this site is managed by Transition"
        else
          $stderr.print "Importing #{filename} ... "
          [TRUNCATE, LOAD_DATA.sub('$filename$', "'#{File.expand_path(filename)}'"), INSERT_FROM_STAGING].each do |statement|
            ActiveRecord::Base.connection.execute(statement)
          end
          $stderr.puts 'done.'
        end
      end

      def self.from_redirector_mask!(filemask)
        Dir[File.expand_path(filemask)].each {|filename| Mappings.from_redirector_csv_file!(filename)}
      end

      def self.managed_by_transition?(filename)
        file = File.new(filename)
        headers = file.gets
        first_row = file.gets
        if first_row.blank?
          false
        else
          first_old_url = first_row.split(',').first
          hostname = URI.parse(first_old_url).host
          host = Host.find_by_hostname(hostname)
          if host
            host.site.managed_by_transition?
          else
            false
          end
        end
      end
    end
  end
end
