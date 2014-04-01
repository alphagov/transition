module Transition
  module Import
    class Hits
      # Lines should probably never be removed from this, only added.
      PATHS_TO_IGNORE = [
        # Generic site furniture
        '/browserconfig.xml',
        '/favicon.ico',
        '/robots.txt',
        '/sitemap.xml',

        # Used in our smokey tests
        '/gdssupertestfakeurl',
        '/thisshouldntwork',
        '/whateverthisshouldntwork',

        # Spam
        '/admin.php',
        '/admin/admin.php',
        '/admin/password_forgotten.php?action=execute',
        '/administrator/index.php',
      ]

      PATTERNS_TO_IGNORE = [
        # Generic site furniture
        '.*\.css',
        '.*\.js',
        '.*\.gif',
        '.*\.ico',
        '.*\.jpg',
        '.*\.jpeg',
        '.*\.png',

        # Often after transition, bots seem to think the old site has
        # www.gov.uk URLs.
        # There are definitely other www.gov.uk URLs, but they are harder to
        # automatically exclude.
        # Whilst we were able to find two *.gov.uk sites using /browse/ or
        # /government/ the numbers of URLs were very small and they are not
        # sites which will transition to GOV.UK.
        '/browse/.*',
        '/government/.*',

        # Spam
        '.*\.bat',
        '.*\.ini',
        '.*/etc/passwd.*',
        '.*/proc/self/environ.*',
        '.*phpMyAdmin.*',
        '.*sqlpatch.php.*',
        '.*_vti_inf.htm',
        '.*_vti_rpc',
        '.*wp-admin.*',
        '.*wp-cron.*',
        '.*wp-login.*',
      ]

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
        INSERT INTO hits (host_id, path, path_hash, http_status, `count`, hit_on)
        SELECT h.id, st.path, SHA1(st.path), st.http_status, st.count, st.hit_on
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        WHERE  st.count >= 10
        AND    st.path NOT IN (#{ PATHS_TO_IGNORE.map { |path| "'" + path + "'" }.join(', ') })
        AND    st.path NOT REGEXP '#{ PATTERNS_TO_IGNORE.join('|') }'
        ON DUPLICATE KEY UPDATE hits.count=st.count
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
        begin
          Dir[File.expand_path(filemask)].each do |filename|
            Hits.from_redirector_tsv_file!(filename)
            done += 1
          end
          ActiveRecord::Base.connection.execute('COMMIT')
        ensure
          ActiveRecord::Base.connection.execute('SET autocommit=1')
        end

        $stderr.puts "#{done} hits files imported."
      end
    end
  end
end
