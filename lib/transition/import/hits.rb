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
        INSERT IGNORE INTO hits (host_id, path, path_hash, http_status, `count`, hit_on, created_at, updated_at)
        SELECT h.id, st.path, SHA1(st.path), st.http_status, st.count, st.hit_on, NOW(), NOW()
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname;
      mySQL

      def self.from_redirector_tsv_file!(filename)
        $stderr.print "Importing #{filename} ... "
        [
          TRUNCATE,
          LOAD_DATA.sub('$filename$', "'#{File.expand_path(filename)}'"),
          INSERT_FROM_STAGING
        ].flatten.each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
        $stderr.puts 'done.'
      end

      def self.from_redirector_mask!(filemask)
        done = 0
        ActiveRecord::Base.connection.execute('SET autocommit=0')
        Dir[File.expand_path(filemask)].each do |filename|
          Hits.from_redirector_tsv_file!(filename)
          done += 1
        end
        ActiveRecord::Base.connection.execute('COMMIT')

        $stderr.puts "#{done} hits files imported."
      end
    end
  end
end
