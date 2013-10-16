Feature: All traffic for site
  As a GDS transition manager/GDS performance analyst
  I want to see all hits to a site
  So that I can see what to fix next

Scenario: Hits exist and are ordered for a site
  Given I have logged in as a GDS user
  And some hits exist for the Attorney General's office site
  And some hits exist for the Cabinet Office site
  When I visit the associated organisation
  And I click the link "View Hits"
  Then I should see all hits for the Attorney General's office in descending count order
  And the hits should be aggregated by status
  And each path should be a link to the real URL
  And the top hit should be represented by a 100% bar
  And subsequent hits should have smaller bars
  But I should not see hits for the Cabinet Office site

Scenario: No hits exist
  Given I have logged in as a GDS user
  And no hits exist for the Attorney General's office site
  When I visit the associated organisation
  And I click the link "View Hits"
  Then I should see "We don’t have any traffic data for ago yet."
