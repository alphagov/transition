Given(/^there are errors for one organisation but not for another$/) do
  site1 = create :site, :with_mappings_and_hits
  create :hit, :error, count: 99, path: "/path-2"
  # this will have no hits and will generate a <td></td> for errors
  create :site

  create :hit, :error, count: 1000, path: "/path-1", hit_on: Time.zone.now, host: site1.default_host

  # The leaderboard uses daily_hit_totals. Set this up.
  Transition::Import::DailyHitTotals.from_hits!
end
