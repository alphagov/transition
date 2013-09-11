Feature: List organisations
  As a GDS User,
  I would like to see a list of organisations
  so that I can get to the mappings for a site

  Scenario: Visit the list page
    Given I have logged in as a GDS user
    And there are 2 organisations
    When I visit the home page
    Then I should see the header "Organisations"
    And I should see a table with class "organisations" containing 2 rows
    And I should see "Signed in"
