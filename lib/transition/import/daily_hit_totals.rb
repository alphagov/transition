module Transition
  module Import
    class DailyHitTotals
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
        $stderr.print 'Refreshing daily hit totals from hits ... '
        raise RuntimeError, "Postgres TODO 4: #{self}.#{__method__} INSERT INTO"
        [ PRECOMPUTE_TOTALS_FROM_HITS ].each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
        $stderr.puts 'done.'
      end
    end
  end
end
