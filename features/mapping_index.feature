Feature: List mappings for a site
  As a GDS User with an interest in the quality of mappings,
  I want to see the list of mappings
  so that I can see the status of many mappings at once

  Background:
    Given I have logged in as an admin
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | http_status | path             | new_url                                 |
      | 301         | /a               | http://gov.uk/directgov                 |
      | 301         | /about/branding  | http://gov.uk/branding                  |
      | 410         | /about/corporate |                                         |
    And I visit the path /sites/directgov/mappings

  Scenario: Selecting multiple mappings to edit without javascript
    When I click on the checkboxes for the first and second mappings
    And I submit the form with the "Edit Checked" button
    Then the page title should be "Edit mappings"
    And I should see "/a"
    And I should see "/about/branding"
    And I should have 2 hidden inputs for mapping IDs
    But I should not see "/about/corporate"
