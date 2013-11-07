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
    When I make the mapping a redirect from /somewhere to http://gov.uk/organisations/bis
    And I save the mapping
    Then I should be returned to the mappings list for bis
    And I should see "Mapping saved."

