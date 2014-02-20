Feature: Edit a site's mapping
  As a GDS user,
  I would like to edit a bad mapping
  so that the mapping begins to send people to the right place

  Background:
    Given I have logged in as an admin
    And a 410 mapping exists for the bis site with the path /about
    And I visit the path /sites/bis/mappings?fake_param=1
    And I go to edit the first mapping

  Scenario: Looking at the example URL
    Then I should see "http://bis.gov.uk/about"
    And I should see "http://webarchive.nationalarchives.gov.uk/20120816224015/http://bis.gov.uk/about"

  @javascript
  Scenario: Editing a site mapping that is a redirect
    When I make the mapping a redirect to https://gov.uk/new-url
    Then I should see redirect fields
    But I should not see archive fields
    When I save the mapping
    Then I should be returned to the mappings list I was on
    And I should see an open modal window
    And I should see "Mapping saved" in the modal window
    And I should see a table that contains the mappings I saved within the modal

  @javascript
  Scenario: Editing a site mapping that is an archive
    When I make the mapping an archive
    Then I should not see redirect fields
    But I should see archive fields

  @javascript
  Scenario: Adding an alternative archive URL
    When I click the link "Use an alternative"
    Then I should see the national archive link replaced with an alternative national archive field
    When I enter an archive URL but then click "Cancel"
    Then I should see the national archive link again
    When I click the link "Use an alternative"
    Then the archive URL field should be empty

  @javascript
  Scenario: Adding a suggested URL
    When I click the link "Suggest a private sector URL"
    Then I should see the link replaced with a suggested URL field

  Scenario: Editing a mapping with invalid values
    When I make the mapping a redirect to http:////not-a-url
    And I save the mapping
    Then I should still be editing a mapping
    And I should see "New URL is not a URL"
