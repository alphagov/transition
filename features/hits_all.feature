Feature: All traffic for site
  As a GDS transition manager/GDS performance analyst
  I want to see all hits to a site
  So that I can see what to fix next and can fix it

Scenario: Hits exist and are ordered for a site
  Given I have logged in as an admin
  And these hits exist for the Attorney General's office site:
    | http_status | path | hit_on   | count |
    | 410         | /    | 16/10/12 | 100   |
    | 301         | /    | 16/10/12 | 100   |
    | 410         | /2   | 16/10/12 | 100   |
    | 301         | /2   | 16/10/12 | 100   |
    | 410         | /    | 17/10/12 | 100   |
    | 301         | /    | 17/10/12 | 100   |
    | 410         | /2   | 17/10/12 | 100   |
    | 301         | /2   | 17/10/12 | 100   |
    | 301         | /2   | 18/10/12 | 100   |
  And some hits exist for the Cabinet Office site
  When I visit the associated site's hits
  Then I should see all hits for the Attorney General's office in descending count order
  And the hits should be grouped by path and status
  And each path should be a link to the real URL
  And the top hit should be represented by a 100% bar
  And subsequent hits should have smaller bars
  And each hit should have a link to check its mapping
  But I should not see hits for the Cabinet Office site

Scenario: No hits exist
  Given I have logged in as an admin
  And no hits exist for the Attorney General's office site
  When I visit the associated site's hits
  Then I should see "We don’t have any traffic data for ago yet."

Scenario: Check mapping for a hit
  Given I have logged in as an admin
  And these hits exist for the Attorney General's office site:
    | http_status | path | hit_on   | count |
    | 301         | /    | 16/10/12 | 100   |
    | 404         | /A   | 16/10/12 | 100   |
    | 404         | /A   | 17/10/12 | 100   |
  And no mapping exists for the top hit
  And I am on the Attorney General's office site's hits page
  When I click on the link to check the mapping for the top hit
  Then I should be on the add mapping page
  And the top hit's canonicalized path should already be in the form
