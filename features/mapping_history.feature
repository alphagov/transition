Feature: History of edits to a mapping
  As a SIRO
  I want to know who edited what, when
  So that people can be held accountable for changes

  Background: Bob has made a good mapping bad. Oh, Bob.
    Given I have logged in as a GDS user called "Bob"
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | http_status | path             | new_url                                 |
      | 301         | /about/corporate | http://somewhere.good                   |
    And I visit the path /sites/directgov/mappings
    And I click the link "Edit"
    And I change the mapping's New URL to http://somewhere.bad

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
    Then I should see that New URL was changed from http://somewhere.good to http://somewhere.bad
    And I should see a link to "Edit"

  Scenario: Looking at a mapping that has been bulk uploaded from redirector
    Given I log in as a SIRO
    And there is a mapping that has no history
    When I go to edit that mapping
    Then I should see no history

