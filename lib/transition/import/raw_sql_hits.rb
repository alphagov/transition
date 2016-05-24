require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class RawSqlHits < Hits
      include Transition::Import::ConsoleJobWrapper

      def self.update!(date)
        ActiveRecord::Base.connection.execute(TRUNCATE)
        ActiveRecord::Base.connection.execute(fold(date))
        ActiveRecord::Base.connection.execute(delete(date))
        ActiveRecord::Base.connection.execute(INSERT_FROM_STAGING)
        ActiveRecord::Base.connection.execute(UPDATE_FROM_STAGING)
      end

      def self.delete(date)
        <<-POSTGRESQL
        DELETE FROM requests
        WHERE hit_on = '#{ date }'
        POSTGRESQL
      end

      def self.fold(date)
        <<-POSTGRESQL
        INSERT INTO hits_staging
        SELECT hostname, path, http_status, COUNT(id), hit_on
        FROM requests
        GROUP BY hostname, path, http_status, hit_on
        HAVING hit_on = '#{ date }'
        POSTGRESQL
      end
    end
  end
end
