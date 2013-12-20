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
    Then I should see "3 mappings"

  @javascript
  Scenario: Selecting multiple mappings to redirect with javascript
    When I select the first two mappings
    And I click the first link called "Redirect selected"
    Then I should see an open modal window
    And I should see a form that contains my selection within the modal
    And I should see "Redirect mappings" in the modal window
    When I enter a new URL to redirect to
    And I save my changes
    Then I should see "Mappings updated"

  @javascript
  Scenario: Selecting multiple mappings to archive with javascript
    When I select the first two mappings
    And I click the first link called "Archive selected"
    Then I should see an open modal window
    And I should see a form that contains my selection within the modal
    And I should see "Archive mappings" in the modal window
    When I save my changes
    Then I should see "Mappings updated"
