module Transition
  module Import
    class Hits
      TRUNCATE = <<-mySQL
        TRUNCATE hits_staging
      mySQL

      LOAD_DATA = <<-mySQL
        LOAD DATA LOCAL INFILE $filename$
        INTO TABLE
          hits_staging
        FIELDS TERMINATED BY '\t'
        LINES TERMINATED BY '\\n'
        IGNORE 1 LINES
          (hit_on, count, http_status, hostname, path)
      mySQL

      INSERT_FROM_STAGING = <<-mySQL
        INSERT INTO hits (host_id, path, path_hash, http_status, `count`, hit_on, created_at, updated_at)
        SELECT h.id, st.path, SHA1(st.path), st.http_status, st.count, st.hit_on, NOW(), NOW()
        FROM
          hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        ON DUPLICATE KEY UPDATE count = st.count, updated_at = NOW()
      mySQL

      def self.from_redirector_tsv_file!(filename)
        $stderr.print "Importing #{filename} ... "
        [TRUNCATE, LOAD_DATA.sub('$filename$', "'#{File.expand_path(filename)}'"), INSERT_FROM_STAGING].each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
        $stderr.puts 'done.'
      end

      def self.from_redirector_mask!(filemask)
        Dir[File.expand_path(filemask)].each {|filename| Hits.from_redirector_tsv_file!(filename)}
      end
    end
  end
end
