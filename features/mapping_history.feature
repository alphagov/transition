Feature: History of edits to a mapping
  As a SIRO
  I want to know who edited what, when
  So that people can be held accountable for changes

  Scenario: Looking at an edited mapping
    Given I have logged in as a GDS user called "Bob"
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | http_status | path             | new_url                                 |
      | 301         | /about/corporate | http://somewhere.good                   |
    And I visit the path /sites/directgov/mappings
    And I click the link "Edit"
    And I change the mapping's New URL to http://somewhere.bad
    When I log in as a SIRO
    And I visit the path /sites/directgov/mappings
    And I click the link "Edit"
    Then I should see that Bob is responsible for the update
