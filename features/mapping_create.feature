Feature: Create mappings
  As a GDS user with an interest in mappings,
  I want to create mappings
  so that previously unknown URLs start to send people to the right place

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
    And I submit the mappings
    Then I should see "Confirm new mappings"
    And I should see "2 existing mappings"
    And I should see "3 old paths"
    And I should see "https://www.gov.uk/organisations/bis"
    And I should see "/needs/canonicalizing"
    And I should see "/a currently archived"
    And I should see "/r currently redirects to http://somewhere.good"
    But I should not see "noslash"
    When I save my changes
    Then I should see "1 mapping created and 0 mappings updated"
    And I should see "/needs/canonicalizing"

  Scenario: I don't have access
    Given I have logged in as a member of another organisation
    And a site bis exists
    And I visit the path /sites/bis/mappings
    Then I should not see "Add mappings"
    And I visit the path /sites/bis/mappings/new
    Then I should see "You don't have permission to edit site mappings for"
    And I visit the path /sites/bis/mappings/new_multiple
    Then I should see "You don't have permission to edit site mappings for"

  Scenario: Errors shown for invalid inputs
    Given I have logged in as an admin
    And a site bis exists
    And I visit the path /sites/bis/mappings
    And I go to create some mappings
    When I make the new mapping paths "noslash" redirect to __INVALID_URL__
    And I submit the mappings
    Then I should see "Enter at least one valid path"
    And I should see a highlighted "Old URLs" label and field
    And the "Old URLs" value should be "noslash"
    And I should see "Enter a valid URL to redirect to"
    And I should see a highlighted "Redirect to" label and field
    And the "Redirect to" value should be "__INVALID_URL__"
