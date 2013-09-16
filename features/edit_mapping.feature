Feature: Edit a site's mapping
  As a GDS user,
  I would like to edit a bad mapping
  so that the mapping begins to send people to the right place

  Background:
    Given I have logged in as a GDS user
    And a 410 mapping exists for the bis site with the path /about

  Scenario: Editing a site mapping with valid values
    When I visit the path /sites/bis/mappings
    And I edit the first mapping
    And I change the mapping to a 301 with a new URL of https://gov.uk/new-url
    And I save the mapping
    Then I should be returned to the mappings list for bis
    And I should see "Mapping saved"
    And I should see "https://gov.uk/new-url"

  Scenario: Editing a mapping with invalid values
    When I visit the path /sites/bis/mappings
    And I edit the first mapping
    And I change the mapping to a 301 with a new URL of not-a-url
    And I save the mapping
    Then I should still be editing a mapping
    And I should see "New url is not a URL"

