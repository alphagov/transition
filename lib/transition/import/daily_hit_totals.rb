require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class DailyHitTotals
      extend ConsoleJobWrapper

      PRECOMPUTE_TOTALS_FROM_HITS = <<-mySQL
        INSERT INTO daily_hit_totals (host_id, http_status, `count`, total_on)
        (
          SELECT host_id, http_status, SUM(count) as `count`, hit_on
          FROM hits
          GROUP BY host_id, http_status, hit_on
        )
        ON DUPLICATE KEY UPDATE `count` = VALUES(`count`)
      mySQL

      def self.from_hits!
        start 'Refreshing daily hit totals from hits' do
          [ PRECOMPUTE_TOTALS_FROM_HITS ].each do |statement|
            ActiveRecord::Base.connection.execute(statement)
          end
        end
      end
    end
  end
end
