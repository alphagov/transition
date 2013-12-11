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

  Scenario: Selecting multiple mappings to redirect without javascript
    When I click on the checkboxes for the first and second mappings
    And I submit the form with the "Edit selected" button
    Then the page title should be "Redirect mappings"
    And I should see "/a"
    And I should see "/about/branding"
    And I should have 2 hidden inputs for mapping IDs
    And I should see a "Redirect to" input
    But I should not see "/about/corporate"

  Scenario: Selecting multiple mappings to archive without javascript
    When I click on the checkboxes for the first and second mappings
    And I select "Archive"
    And I submit the form with the "Edit selected" button
    Then the page title should be "Archive mappings"
    And I should see "/a"
    And I should see "/about/branding"
    And I should have 2 hidden inputs for mapping IDs
    And I should not see a "Redirect to" input
