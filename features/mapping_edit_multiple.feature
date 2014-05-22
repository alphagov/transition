Feature: Editing multiple mappings for a site
  As a GDS User,
  I want to update many existing mappings at once
  so that I can efficiently improve the quality of mappings

  Background:
    Given I have logged in as an admin
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | type     | path             | new_url                                 |
      | redirect | /a               | http://gov.uk/directgov                 |
      | redirect | /about/branding  | http://gov.uk/branding                  |
      | archive  | /about/corporate |                                         |
      | archive  | /z1              |                                         |
      | archive  | /z2              |                                         |
      | archive  | /z3              |                                         |
      | archive  | /z4              |                                         |
      | archive  | /z5              |                                         |
      | archive  | /z6              |                                         |
      | archive  | /z7              |                                         |
      | archive  | /z8              |                                         |
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
    Then I should see "11 mappings"

  Scenario: Editing multiple mappings from a filtered index page
    When I click the link "Filter mappings"
    And I filter the path by /about
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
    And an analytics event with "bulk-edit-redirect" has fired
    When I enter a new URL to redirect to
    And I save my changes
    Then I should see an open modal window
    And I should see "Mappings updated" in the modal window
    And I should see a table with 2 saved mappings in the modal
    And I should see "/a" in the modal window
    And I should see "/about/branding" in the modal window
    And an analytics event with "bulk-edit-redirect" has fired

  @javascript
  Scenario: Selecting multiple mappings to archive with javascript
    When I select the first two mappings
    And I click the first link called "Archive"
    Then I should see an open modal window
    And I should see a form that contains my selection within the modal
    And I should see "Archive mappings" in the modal window
    And an analytics event with "bulk-edit-archive" has fired
    When I save my changes
    Then I should see an open modal window
    And I should see "Mappings updated" in the modal window
    And I should see a table with 2 saved mappings in the modal
    And I should see "/a" in the modal window
    And I should see "/about/branding" in the modal window
    And an analytics event with "bulk-edit-archive" has fired

  @javascript
  Scenario: Truncating a table of mappings in a modal
    When I select all the mappings
    And I click the first link called "Redirect"
    Then I should see an open modal window
    And I should see a table with 9 mappings in the modal
    When I click the link "and 2 more"
    Then I should see a table with 11 mappings in the modal
    And I should not see "and 2 more"

  @javascript
  Scenario: Don't truncate a table of exactly 10 mappings
    When I select the first 10 mappings
    And I click the first link called "Redirect"
    Then I should see an open modal window
    And I should see a table with 10 mappings in the modal
