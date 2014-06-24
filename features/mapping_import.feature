Feature: Import mappings
  As a user with a spreadsheet of mappings
  I want to import them to Transition
  So that I can continue to edit them there
  And so that the mappings take effect

  Scenario: Successfully importing mappings
    Given I have logged in as a GDS Editor
    And there is a site called bis belonging to an organisation bis with these mappings:
      | type    | path        | new_url | tags |
      | archive | /archive-me |         |      |
    And I visit the path /sites/bis
    And I go to import some mappings
    Then I should see "http://bis.gov.uk"
    When I submit the form with valid CSV
    Then the page title should be "Preview import"
    And I should see options to keep or overwrite the existing mappings
    And I should see how many of each type of mapping will be created
    And I should see how many mappings will be overwritten
    And I should see a preview of my mappings

  Scenario: I don't have access
    Given I have logged in as a member of another organisation
    And a site bis exists
    And I visit the path /sites/bis/mappings
    Then I should not see "import from a spreadsheet"
    And I visit the path /sites/bis/mappings/import_batches/new
    Then I should see "You don't have permission to edit mappings for"
