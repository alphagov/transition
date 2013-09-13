Feature: Paginated mappings
  As a GDS'er with an interest in the performance of mappings,
  I would like to see a list of mappings to edit
  so that I can find one to edit

  Scenario: There are no mappings for a site
    Given I have logged in as a GDS user
    And there is a site called bis_lowpay belonging to an organisation bis with these mappings:
      | http_status | path             | new_url           |
    When I visit the path /organisations/bis
    And I click the link called "bis_lowpay"
    Then I should see the header "Mappings"
    And I should see "No mappings found."

  Scenario: There are mappings for a site and we visit page 1
    Given I have logged in as a GDS user
    And there is a site called bis_lowpay belonging to an organisation bis with these mappings:
      | http_status | path             | new_url           |
      | 410         | /about/corporate |                   |
      | 301         | /                | http://gov.uk/bis |
      | 410         | /something       |                   |
    And the mappings page size is 2
    When I visit the path /organisations/bis
    And I click the link called "bis_lowpay"
    Then I should see the header "Mappings"
    And  I should see "bis_lowpay"
    And  I should see a table with class "mappings" containing 2 rows
    And  I should see 1 as the current page
    And  I should see a link to page 2

  Scenario: There are mappings for a site and we visit page 2
    Given I have logged in as a GDS user
    And there is a site called bis_lowpay belonging to an organisation bis with these mappings:
      | http_status | path             | new_url           |
      | 410         | /about/corporate |                   |
      | 301         | /                | http://gov.uk/bis |
      | 410         | /something       |                   |
    And the mappings page size is 2
    When I visit the path /organisations/bis
    And I click the link called "bis_lowpay"
    And I click the link called "2"
    And  I should see a table with class "mappings" containing 1 row
    And  I should see 2 as the current page
    And  I should see a link to page 1


