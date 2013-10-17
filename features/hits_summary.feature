Feature: Summary traffic for site
  As a GDS transition manager/GDS performance analyst
  I want to see a summary of traffic to a site
  So that I can more easily decide what to fix next based on performance

Background:
  Given I have logged in as a GDS user
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
  When I visit the associated organisation
  And I click the link "Hits Summary"

Scenario: Hits exist and are summarised for a site
  Then I should see a section for the most common errors on the Attorney General's office
  And it should show only the top ten errors in descending count order
  And I should see a section for the most common archives
  And it should show only the top ten archives in descending count order
  And I should see a section for the most common redirects
  And it should show only the top ten redirects in descending count order

Scenario: Hits exist and can be filtered by error
  And I click the link "Errors"
  Then I should see all hits with an error status for the Attorney General's office in descending count order
  
Scenario: Hits exist and can be filtered by archives
  And I click the link "Archives"
  Then I should see all hits with an archive status for the Attorney General's office in descending count order
  
Scenario: Hits exist and can be filtered by redirects
  And I click the link "Redirects"
  Then I should see all hits with a redirect status for the Attorney General's office in descending count order
