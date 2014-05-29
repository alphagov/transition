Feature: Analytics for all sites
  As a GDS performance analyst
  I want to see analytics across all transitioning sites
  So that I can see what the worst errors and most popular archives are

Background: There are hits from many sites
  Given I have logged in as a GDS Editor
  And some hits exist for the Attorney General, Cabinet Office and FCO sites:
  | http_status | path | hit_on   | count |
  | 301         | /    | 17/10/12 | 100   |
  | 301         | /2   | 17/10/12 | 100   |
  | 301         | /3   | 18/10/12 | 100   |
  | 301         | /4   | 18/10/12 | 100   |
  | 301         | /5   | 18/10/12 | 100   |
  | 301         | /6   | 18/10/12 | 100   |
  | 301         | /7   | 18/10/12 | 100   |
  | 301         | /8   | 18/10/12 | 100   |
  | 301         | /9   | 18/10/12 | 100   |
  | 301         | /10  | 18/10/12 | 100   |
  | 301         | /11  | 18/10/12 | 10    |
  | 301         | /12  | 10/08/12 | 10    |
  | 410         | /    | 17/10/12 | 100   |
  | 410         | /2   | 17/10/12 | 100   |
  | 410         | /3   | 18/10/12 | 100   |
  | 410         | /4   | 18/10/12 | 100   |
  | 410         | /5   | 18/10/12 | 100   |
  | 410         | /6   | 18/10/12 | 100   |
  | 410         | /7   | 18/10/12 | 100   |
  | 410         | /8   | 18/10/12 | 100   |
  | 410         | /9   | 18/10/12 | 100   |
  | 410         | /10  | 18/10/12 | 100   |
  | 410         | /11  | 18/10/12 | 10    |
  | 410         | /12  | 10/08/12 | 10    |
  | 404         | /    | 17/10/12 | 100   |
  | 404         | /2   | 17/10/12 | 100   |
  | 404         | /3   | 18/10/12 | 100   |
  | 404         | /4   | 18/10/12 | 100   |
  | 404         | /5   | 18/10/12 | 100   |
  | 404         | /6   | 18/10/12 | 100   |
  | 404         | /7   | 18/10/12 | 100   |
  | 404         | /8   | 18/10/12 | 100   |
  | 404         | /9   | 18/10/12 | 100   |
  | 404         | /10  | 18/10/12 | 100   |
  | 404         | /11  | 18/10/12 | 10    |
  | 404         | /12  | 10/08/12 | 10    |
  | 200         | /    | 17/10/12 | 100   |
  | 200         | /2   | 17/10/12 | 100   |
  | 200         | /3   | 18/10/12 | 100   |
  | 200         | /4   | 18/10/12 | 100   |
  | 200         | /5   | 18/10/12 | 100   |
  | 200         | /6   | 18/10/12 | 100   |
  | 200         | /7   | 18/10/12 | 100   |
  | 200         | /8   | 18/10/12 | 100   |
  | 200         | /9   | 18/10/12 | 100   |
  | 200         | /10  | 18/10/12 | 100   |
  | 200         | /11  | 18/10/12 | 10    |
  | 200         | /12  | 10/08/12 | 10    |
  And the date is 19/10/12
  When I visit universal analytics

Scenario: Hits for all sites are shown in a summary
  Then I should see hits for the Attorney General, Cabinet Office and FCO sites
  And I should see sections for the most common errors, archives and redirects
  And it should show only the top 10 errors in descending count order
  And it should show only the top 10 archives in descending count order
  And it should show only the top 10 redirects in descending count order

Scenario: Hits exist and show the last 30 days by default
  When I click the link "Redirects"
  Then I should see hits from the last 30 days with a redirect status, in descending count order
  And I should see hits for the Attorney General, Cabinet Office and FCO sites
  And the period "Last 30 days" should be selected

Scenario: Hits exist and can be filtered by error and time period "Yesterday"
  When I click the link "Errors"
  And I filter by the date period "Yesterday"
  Then I should see only yesterday's errors in descending count order
  And the period "Yesterday" should be selected
  And I should see hits for the Attorney General, Cabinet Office and FCO sites

Scenario: Hits exist and can be filtered by archives
  When I click the link "Archives"
  Then I should see hits from the last 30 days with an archive status, in descending count order
  And I should see hits for the Attorney General, Cabinet Office and FCO sites

Scenario: Hits exist and can be filtered by redirects and time period "All time"
  When I click the link "Redirects"
  And I filter by the date period "All time"
  Then I should see all hits with a redirect status, in descending count order
  And I should see hits for the Attorney General, Cabinet Office and FCO sites
  And the period "All time" should be selected
