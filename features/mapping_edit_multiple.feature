Feature: Editing multiple mappings for a site
  As a GDS User,
  I want to update many existing mappings at once
  so that I can efficiently improve the quality of mappings

  Background:
    Given I have logged in as an admin
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | http_status | path             | new_url                                 |
      | 301         | /a               | http://gov.uk/directgov                 |
      | 301         | /about/branding  | http://gov.uk/branding                  |
      | 410         | /about/corporate |                                         |
      | 410         | /z1              |                                         |
      | 410         | /z2              |                                         |
      | 410         | /z3              |                                         |
      | 410         | /z4              |                                         |
      | 410         | /z5              |                                         |
      | 410         | /z6              |                                         |
      | 410         | /z7              |                                         |
      | 410         | /z8              |                                         |
      | 410         | /z9              |                                         |
      | 410         | /z10             |                                         |
      | 410         | /z11             |                                         |
      | 410         | /z12             |                                         |
    And I visit the path /sites/directgov/mappings

  Scenario: Selecting multiple mappings to redirect without javascript
    When I select the first two mappings
    And I go to edit the selected mappings
    Then the page title should be "Redirect mappings"
    And I should see a form that contains my selection
    And I should see a "Redirect to" input

  Scenario: Selecting multiple mappings to archive without javascript
    When I select the first two mappings
    And I select "Archive"
    And I go to edit the selected mappings
    Then the page title should be "Archive mappings"
    And I should see a form that contains my selection
    And I should not see a "Redirect to" input

  Scenario: Confirming multiple mappings to redirect without javascript
    When I select the first two mappings
    And I go to edit the selected mappings
    And I enter a new URL to redirect to
    And I save my changes
    Then I should see "Mappings updated"

  Scenario: Confirming multiple mappings to redirect but without entering a new URL
    When I select the first two mappings
    And I go to edit the selected mappings
    And I save my changes
    Then the page title should be "Redirect mappings"
    And I should see "Enter a valid URL"

  Scenario: Cancelling an attempt to redirect multiple mappings after entering several invalid URLs
    When I select the first two mappings
    And I go to edit the selected mappings
    And I save my changes
    And I click the link called "Cancel"
    Then I should see "15 mappings"

  Scenario: Editing multiple mappings from a filtered index page
    When I filter the path by /about
    And I select the first two mappings
    And I select "Archive"
    And I go to edit the selected mappings
    And I save my changes
    Then I should see "2 mappings"
    And the filter box should contain "/about"

  @javascript
  Scenario: Selecting multiple mappings to redirect with javascript
    When I select the first two mappings
    And I click the first link called "Redirect"
    Then I should see an open modal window
    And I should see a form that contains my selection within the modal
    And I should see "Redirect mappings" in the modal window
    When I enter a new URL to redirect to
    And I save my changes
    Then I should see an open modal window
    And I should see "Mappings updated" in the modal window
    And I should see a table with 2 saved mappings in the modal
    And I should see "/a" in the modal window
    And I should see "/about/branding" in the modal window

  @javascript
  Scenario: Selecting multiple mappings to archive with javascript
    When I select the first two mappings
    And I click the first link called "Archive"
    Then I should see an open modal window
    And I should see a form that contains my selection within the modal
    And I should see "Archive mappings" in the modal window
    When I save my changes
    Then I should see an open modal window
    And I should see "Mappings updated" in the modal window
    And I should see a table with 2 saved mappings in the modal
    And I should see "/a" in the modal window
    And I should see "/about/branding" in the modal window
