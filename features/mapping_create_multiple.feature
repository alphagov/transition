Feature: Create mappings
  As a GDS user with an interest in mappings,
  I want to create mappings
  so that previously unknown URLs start to send people to the right place

  @javascript
  Scenario:
    Given I have logged in as an admin
    And there is a site called bis belonging to an organisation bis with these mappings:
      | http_status | path | new_url               |
      | 301         | /r   | http://somewhere.good |
      | 410         | /a   |                       |
    And I visit the path /sites/bis/mappings
    And I go to create some mappings
    Then I should see "http://bis.gov.uk"
    When I make the new mapping paths "/Needs/Canonicalizing/?q=1, /a, /r, noslash" redirect to www.gov.uk/organisations/bis
    And I continue
    Then the page title should be "Confirm new mappings"
    And I should see options to ignore or overwrite the existing mappings
    And I should see that the mappings will redirect to "https://www.gov.uk/organisations/bis"
    And I should see the canonicalized paths "/needs/canonicalizing, /a, /r"
    But I should not see "noslash"
    And I should see "/a currently archived"
    And I should see "/r currently redirects to http://somewhere.good"
    When I save my changes
    Then I should see "1 mapping created. 0 mappings updated." in a modal window
    And I should see a table with 1 saved mapping in the modal
    And I should see "/needs/canonicalizing" in a modal window
    And an analytics event with "bulk-add-redirect-ignore-existing" has fired

  Scenario: I don't have access
    Given I have logged in as a member of another organisation
    And a site bis exists
    And I visit the path /sites/bis/mappings
    Then I should not see "Add mappings"
    And I visit the path /sites/bis/mappings/new_multiple
    Then I should see "You don't have permission to edit mappings for"

  Scenario: Errors shown for invalid inputs
    Given I have logged in as an admin
    And a site bis exists
    And I visit the path /sites/bis/mappings
    And I go to create some mappings
    When I make the new mapping paths "noslash" redirect to __INVALID_URL__
    And I continue
    Then I should see "Enter at least one valid path"
    And I should see a highlighted "Old URLs" label and field
    And the "Old URLs" value should be "noslash"
    And I should see "Enter a valid URL to redirect to"
    And I should see a highlighted "Redirect to" label and field
    And the "Redirect to" value should be "__INVALID_URL__"
