Feature: Edit a site's mapping
  As a GDS user,
  I would like to edit a bad mapping
  so that the mapping begins to send people to the right place

  Background:
    Given I have logged in as an admin
    And a 410 mapping exists for the bis site with the path /about
    And I visit the path /sites/bis/mappings
    And I go to edit the first mapping

  Scenario: Looking at the example URL
    Then I should see "http://bis.gov.uk/about"

  @javascript
  Scenario: Editing a site mapping that is a redirect
    When I make the mapping a redirect to https://gov.uk/new-url
    Then I should see redirect fields
    But I should not see archive fields
    When I save the mapping
    Then I should be returned to the mappings list for bis
    And I should see "Mapping saved"
    And I should see "https://gov.uk/new-url"

  @javascript
  Scenario: Editing a site mapping that is an archive
    When I make the mapping an archive
    Then I should not see redirect fields
    But I should see archive fields

  Scenario: Editing a mapping with invalid values
    When I make the mapping a redirect to not-a-url
    And I save the mapping
    Then I should still be editing a mapping
    And I should see "New URL is not a URL"

