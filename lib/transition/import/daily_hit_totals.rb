require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class DailyHitTotals
      extend ConsoleJobWrapper

      INSERT_TOTALS_FROM_HITS = <<-postgreSQL
        INSERT INTO daily_hit_totals (host_id, http_status, count, total_on)
          SELECT host_id, http_status, SUM(count) as count, hit_on
          FROM hits
          WHERE NOT EXISTS (
            SELECT 1 FROM daily_hit_totals
            WHERE
              host_id     = hits.host_id AND
              http_status = hits.http_status AND
              total_on    = hits.hit_on
          )
          GROUP BY host_id, http_status, hit_on
      postgreSQL

      UPDATE_TOTALS_FROM_HITS = <<-postgreSQL
        UPDATE daily_hit_totals totals SET count = sums.count
        FROM (
          SELECT host_id, http_status, SUM(count) AS count, hit_on
          FROM hits
          GROUP BY host_id, http_status, hit_on
        ) AS sums
        WHERE
          totals.host_id     = sums.host_id AND
          totals.http_status = sums.http_status AND
          totals.total_on    = sums.hit_on AND
          totals.count IS DISTINCT FROM sums.count
      postgreSQL

      def self.from_hits!
        start 'Refreshing daily hit totals from hits' do
          ActiveRecord::Base.connection.execute(UPDATE_TOTALS_FROM_HITS)
          ActiveRecord::Base.connection.execute(INSERT_TOTALS_FROM_HITS)
        end
      end
    end
  end
end
