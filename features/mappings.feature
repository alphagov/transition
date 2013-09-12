Feature: Paginated mappings
  As a GDS'er with an interest in the performance of mappings,
  I would like to see a list of mappings to edit
  so that I can find one to edit

  Scenario: There are no mappings for a site
    Given I have logged in as a GDS user
    And there is a site called bis_lowpay belonging to an organisation bis with these mappings:
      | http_status | path             | new_url           |
    When I visit the path /organisations/bis
    And  click the link called "bis_lowpay"
    Then I should see the header "Mappings"
    And I should see "No mappings found."

  Scenario: There are mappings for a site
    Given I have logged in as a GDS user
    And there is a site called bis_lowpay belonging to an organisation bis with these mappings:
      | http_status | path             | new_url           |
      | 410         | /about/corporate |                   |
      | 301         | /                | http://gov.uk/bis |
      | 410         | /something       |                   |
    When I visit the path /organisations/bis
    And  click the link called "bis_lowpay"
    Then I should see the header "Mappings"
    And  I should see "bis_lowpay"
    And  I should see a table with class "mappings" containing 3 rows


