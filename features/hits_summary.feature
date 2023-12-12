@javascript
Feature: Summary traffic for site
  As a GDS proposition manager/GDS performance analyst
  I want to see a summary of traffic to a site
  So that I can more easily decide what to fix next based on performance

Background: I start at the summary page
  Given I have logged in as a GDS Editor
  And the date is 19/10/12
  And these hits exist for the Attorney General's office site:
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
  When I visit the associated site
  And I click the link "Analytics"

Scenario: Hits exist and are summarised for a site, displayed with a graph
  Then I should see a section for the most common errors
  And it should show only the top 10 errors in descending count order
  And I should see a section for the most common archives
  And it should show only the top 10 archives in descending count order
  And I should see a section for the most common redirects
  And it should show only the top 10 redirects in descending count order
  And I should see a graph representing hits data over time
  And I should see a trend for all hits, errors, archives and redirects
  When I click a point for the date 18/10/12
  Then I should see a section for the most common errors
  And it should show only the top 9 errors in descending count order
  But I should not see a graph

Scenario: Hits exist and show the last 30 days by default
  When I click the link "Redirects"
  Then I should see an redirects graph showing a green trend line with 2 points
  And I should see a redirects graph showing a green trend line
  And I should see hits from the last 30 days with a redirect status, in descending count order
  And the period "Last 30 days" should be selected

Scenario: Hits exist and can be filtered by error and time period "Yesterday"
  When I click the link "Errors"
  Then I should see hits from the last 30 days with an error status, in descending count order
  And I should see an errors graph showing a red trend line
  When I filter by the date period "Yesterday"
  Then I should see only yesterday's errors in descending count order
  And I should not see a graph
  And the period "Yesterday" should be selected

Scenario: Hits exist and can be filtered by archives and time period "Last seven days"
  When I click the link "Archives"
  Then I should see hits from the last 30 days with an archive status, in descending count order
  When I filter by the date period "Last seven days"
  Then I should see an archives graph showing a grey trend line with 2 points
  And the period "Last seven days" should be selected

Scenario: Hits exist and can be filtered by redirects and time period "All time"
  When I click the link "Redirects"
  And I filter by the date period "All time"
  Then I should see all hits with a redirect status, in descending count order
  And the period "All time" should be selected

Scenario: There are multiple pages for a category
  Given the hits page size is 11
  And there are at least two pages of error hits
  When I click the link "Errors"
  And I go to page 2
  Then I should not see a graph

Scenario: No hits exist at all
  Given no hits exist for the Attorney General's office site
  When I visit the associated site
  And I click the link "Analytics"
  Then I should not see a graph
  And I should see "There are no known hits for the ago.gov.uk summary"
  When I click the link "Errors"
  Then I should see "There are no errors for ago.gov.uk"
  And I should not see a graph
  When I filter by the date period "Last seven days"
  Then I should see "There are no errors for ago.gov.uk in this time period"

@allow-rescue
Scenario: Visit the hits summary page for an non-existent site
  Given I have logged in as a GDS Editor
  And I visit the path /sites/not_a_site/hits/summary
  Then I should see our custom 404 page
