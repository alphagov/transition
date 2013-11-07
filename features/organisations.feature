Feature: List organisations
  As a GDS User,
  I would like to see a list of organisations
  so that I can get to the mappings for a site

  Scenario: Visit the list page
    Given I have logged in as an admin
    And there are these organisations:
      | abbr | title                                          |
      | bis  | Department for Business, Innovation and Skills |
      | fco  | Foreign Office                                 |
    When I visit the home page
    Then I should see "Signed in"
    And I should see the header "Organisations"
    And I should see a table with class "organisations" containing 2 rows
    And I should see a link to the organisation bis
    And I should see a link to the organisation fco
