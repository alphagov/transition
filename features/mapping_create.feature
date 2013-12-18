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
