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
          (@old_url, new_url, http_status)
        SET
          host = TRIM(LEADING 'http://' FROM SUBSTRING_INDEX(@old_url, '/', 3)), /* Everything up to the 3rd slash or end of string */
          path = replace(@old_url, SUBSTRING_INDEX(@old_url, '/', 3), ''),       /* wow, this is ugly */
          path_hash = SHA1(path),
          old_url = @old_url
      mySQL

      INSERT_FROM_STAGING = <<-mySQL
        INSERT INTO mappings (site_id, path, path_hash, http_status, new_url)
        SELECT h.site_id, st.path, st.path_hash, st.http_status, new_url
        FROM
          mappings_staging st
        INNER JOIN hosts h on h.hostname = st.host
      mySQL

      def self.from_redirector_csv_file!(filename)
        [TRUNCATE, LOAD_DATA.sub('$filename$', "'#{File.expand_path(filename)}'"), INSERT_FROM_STAGING].each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
      end
    end
  end
end