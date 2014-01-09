Feature: Create a mapping
  As a GDS user with an interest in mappings,
  I want to create a mapping
  so that a previously unknown URL starts to send people to the right place

  Scenario:
    Given I have logged in as an admin
    And a site bis exists
    And I visit the path /sites/bis/mappings
    And I go to create a new mapping
    Then I should see "http://bis.gov.uk"
    When I make the new mapping a redirect from /Needs/Canonicalizing/q=1 to http://gov.uk/organisations/bis
    And I submit the mapping
    Then I should be returned to the edit mapping page with a success message
    And I should see "Mapping created."
    And I should see "/needs/canonicalizing"
    And I should see "http://gov.uk/organisations/bis"

  Scenario: I don't have access
    Given I have logged in as a member of another organisation
    And a site bis exists
    And I visit the path /sites/bis/mappings
    Then I should not see "Add mapping"
    And I visit the path /sites/bis/mappings/new
    Then I should see "You don't have permission to edit site mappings for"
    And I visit the path /sites/bis/mappings/new_multiple
    Then I should see "You don't have permission to edit site mappings for"

  Scenario: Create multiple mappings
    Given I have logged in as an admin
    And a site bis exists
    And I visit the path /sites/bis/mappings/new_multiple
    Then I should see "http://bis.gov.uk"
    When I make the new mapping paths "/Needs/Canonicalizing/q=1, /a, noslash" redirect to www.gov.uk/organisations/bis
    And I submit the mappings
    Then I should see "Confirm new mappings"
    And I should see "https://www.gov.uk/organisations/bis"
    And I should see "/needs/canonicalizing"
    And I should see "/a"
    But I should not see "noslash"

  Scenario: Errors shown for invalid inputs
    Given I have logged in as an admin
    And a site bis exists
    And I visit the path /sites/bis/mappings/new_multiple
    When I make the new mapping paths "" redirect to ______
    And I submit the mappings
    Then I should see "Enter at least one valid path"
    And I should see a highlighted "Old URLs" label and field
    And I should see "Enter a valid URL to redirect to"
    And I should see a highlighted "Redirect to" label and field
