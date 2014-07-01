require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class Hits
      extend ConsoleJobWrapper

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
        # Found in www.ukti.gov.uk logs. See: http://www.spambotsecurity.com/forum/viewtopic.php?p=15489&sid=83d6bc4bcddff28b0e124687e4d8a741#p15489
        '//images/stories/0d4y.php',
        '//images/stories/0day.php',
        '//images/stories/3xp.php',
        '//images/stories/70bex.php',
        '//images/stories/iam.php',
        '//images/stories/itil.php',
        '//images/stories/jahat.php',
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
        '.*\.svg',

        # Font files
        '.*\.eot',
        '.*\.ttf',
        '.*\.woff',

        # Image URLs on www.ukti.gov.uk
        '^/[0-9]+\.image$',
        '^/[0-9]+\.leadimage\?.*',

        # Often after transition, bots seem to think the old site has
        # www.gov.uk URLs.
        # There are definitely other www.gov.uk URLs, but they are harder to
        # automatically exclude.
        # Whilst we were able to find two *.gov.uk sites using /browse/ or
        # /government/ the numbers of URLs were very small and they are not
        # sites which will transition to GOV.UK.
        '/browse/.*',
        '/government/.*',

        # This is used by TNA to resolve pages which are missing from their archive:
        # http://www.nationalarchives.gov.uk/documents/information-management/redirection-technical-guidance-for-departments-v4.2-web-version.pdf
        '/ukgwacnf.html.*',

        # Spam
        '.*\.bat',
        '.*\.htpasswd',
        '.*\.ini',
        '.*/etc/passwd.*',
        '.*/proc/self/environ.*',
        '.*phpMyAdmin.*',
        '.*sqlpatch.php.*',
        '.*_vti_bin.*',
        '.*_vti_inf.htm',
        '.*_vti_pvt.*',
        '.*_vti_rpc',
        '.*wp-admin.*',
        '.*wp-cron.*',
        '.*wp-login.*',
      ]

      TRUNCATE = <<-postgreSQL
        TRUNCATE hits_staging
      postgreSQL

      LOAD_DATA = <<-postgreSQL
        COPY hits_staging (hit_on, count, http_status, hostname, path)
        FROM '$filename$'
        WITH DELIMITER AS E'\t' QUOTE AS E'\b' CSV HEADER;
        ANALYZE hits_staging;
      postgreSQL

      INSERT_FROM_STAGING = <<-postgreSQL
        INSERT INTO hits (host_id, path, path_hash, http_status, count, hit_on)
        SELECT h.id, st.path, encode(digest(st.path, 'sha1'), 'hex'), st.http_status, st.count, st.hit_on
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        WHERE st.path NOT IN (#{ PATHS_TO_IGNORE.map { |path| "'" + path + "'" }.join(', ') })
          AND st.path !~ '#{ PATTERNS_TO_IGNORE.join('|') }'
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
          hits.count      <> st.count
      postgreSQL

      def self.from_redirector_tsv_file!(filename)
        start "Importing #{filename}" do |job|
          expanded_filename = File.expand_path(filename)

          import_record = ImportedHitsFile.where(
            filename: expanded_filename).first_or_initialize

          job.skip! and next if import_record.same_on_disk?

          [
            TRUNCATE,
            LOAD_DATA.sub('$filename$', "'#{expanded_filename}'"),
            INSERT_FROM_STAGING,
            UPDATE_FROM_STAGING
          ].flatten.each do |statement|
            ActiveRecord::Base.connection.execute(statement)
          end

          import_record.save!
        end
      end

      def self.from_redirector_mask!(filemask)
        done, unchanged = 0, 0

        ActiveRecord::Base.connection.execute('BEGIN')
        begin
          Dir[File.expand_path(filemask)].each do |filename|
            Hits.from_redirector_tsv_file!(filename) ? done += 1 : unchanged += 1
          end
          ActiveRecord::Base.connection.execute('COMMIT')
        end

        console_puts "#{done} hits files imported (#{unchanged} unchanged)."

        done
      end
    end
  end
end
