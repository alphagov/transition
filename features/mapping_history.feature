Feature: History of edits to a mapping
  As a SIRO
  I want to know who edited what, when
  So that people can be held accountable for changes

  Background: Bob has made a good mapping bad. Oh, Bob.
    Given I have logged in as a GDS Editor called "Bob"
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | type     | path             | new_url                                 |
      | redirect | /about/corporate | http://somewhere.gov.uk                 |
    And I visit the path /sites/directgov/mappings
    And I click the link "Edit"
    And I change the mapping's redirect to http://bad.gov.uk

  Scenario: Looking at an edited mapping
    When I log in as a SIRO
    And I visit the path /sites/directgov/mappings
    And I click the link "Edit"
    Then I should see "History"

  Scenario: Looking at what changed
    When I log in as a SIRO
    And I visit the path /sites/directgov/mappings
    And I click the link "Edit"
    And I click the tab "History"
    Then I should see that New URL was changed from http://somewhere.gov.uk to http://bad.gov.uk
    And I should see "New URL updated"
    And I should see a link to "Edit"

  Scenario: Looking at a mapping that was imported from transition-config
    Given I log in as a SIRO
    And there is a mapping that has no history
    When I go to edit that mapping
    Then I should see no history

  @allow-rescue
  Scenario: Trying to look at a mapping's history on the wrong site
    When I log in as a SIRO
    And I visit the path /sites/directgov/mappings/1/versions
    Then I should see "History"
    When I visit the path /sites/not_a_site/mappings/1/versions
    Then I should see our custom 404 page
