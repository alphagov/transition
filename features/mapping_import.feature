Feature: Import mappings
  As a user with a spreadsheet of mappings
  I want to import them to Transition
  So that I can continue to edit them there
  And so that the mappings take effect

  @javascript
  Scenario: Successfully importing a small batch of mappings
    Given I have logged in as a GDS Editor
    And there is a site called bis belonging to an organisation bis with these mappings:
      | type    | path        | new_url | tags |
      | archive | /archive-me |         |      |
    And I visit the path /sites/bis
    And I go to import some mappings
    Then I should see "http://bis.gov.uk"

    When I associate the tags "fee,fi,FO" with the mappings
    And I submit the form with a small valid CSV
    Then the page title should be "Preview import"
    And I should see options to keep or overwrite the existing mappings
    And I should see how many of each type of mapping will be created
    And I should see a preview of my small batch of mappings
    And I should see the tags "fee,fi,FO"
    But I should not see how many mappings will be overwritten

    When I choose "Overwrite existing mappings"
    Then I should see how many mappings will be overwritten

    When I click the "Import" button
    Then I should be on the bis mappings page
    And I should see "2 mappings created and 1 mapping updated" in a modal window
    And I should see a table with 3 saved mappings in the modal
    And I should see "/i-dont-know-what-i-am" in a modal window
    And an analytics event with "import-overwrite-existing" has fired

  @javascript
  Scenario: Successfully importing a larger batch of mappings
    Given I have logged in as a GDS Editor
    When I import a large valid CSV for bis
    Then I should see a preview of my large batch of mappings
    When I confirm the preview
    Then I should see prominent progress of the import
    When I navigate away to the bis mappings page
    Then I should see less prominent progress of the import

  Scenario: Importing a batch without Javascript
    Given I have logged in as a GDS Editor
    And there is a site called bis belonging to an organisation bis with these mappings:
      | type    | path        | new_url | tags |
      | archive | /archive-me |         |      |
    And I visit the path /sites/bis
    And I go to import some mappings
    Then I should see "http://bis.gov.uk"
    When I associate the tags "fee,fi,FO" with the mappings
    And I submit the form with a small valid CSV
    Then the page title should be "Preview import"
    And I should see the tags "fee,fi,FO"
    When I click the "Import" button
    Then I should be on the bis mappings page
    And I should see "2 mappings created and tagged"

  Scenario: I don't have access
    Given I have logged in as a member of another organisation
    And a site bis exists
    And I visit the path /sites/bis/mappings
    Then I should not see "import from a spreadsheet"
    And I visit the path /sites/bis/mappings/import_batches/new
    Then I should see "You don't have permission to edit mappings for"
