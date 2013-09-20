Feature: Edit a site's mapping
  As a GDS user,
  I would like to edit a bad mapping
  so that the mapping begins to send people to the right place

  Background:
    Given I have logged in as a GDS user
    And a 410 mapping exists for the bis site with the path /about
    And I visit the path /sites/bis/mappings
    And I go to edit the first mapping

  Scenario: Looking at the example URL
    Then I should see "http://bis.gov.uk/about"

  Scenario: Editing a site mapping with valid values
    When I make the mapping a redirect with a new URL of https://gov.uk/new-url
    And I save the mapping
    Then I should be returned to the mappings list for bis
    And I should see "Mapping saved"
    And I should see "https://gov.uk/new-url"

  Scenario: Editing a mapping with invalid values
    When I make the mapping a redirect with a new URL of not-a-url
    And I save the mapping
    Then I should still be editing a mapping
    And I should see "New url is not a URL"

