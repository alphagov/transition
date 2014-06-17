Feature: Import mappings
  As a user with a spreadsheet of mappings
  I want to import them to Transition
  So that I can continue to edit them there
  And so that the mappings take effect

  Scenario: I don't have access
    Given I have logged in as a member of another organisation
    And a site bis exists
    And I visit the path /sites/bis/mappings
    Then I should not see "import from a spreadsheet"
    And I visit the path /sites/bis/mappings/import_batches/new
    Then I should see "You don't have permission to edit mappings for"
