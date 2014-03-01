Feature: Filter mappings
  As a GDS User with an interest in the quality of mappings,
  I want to filter the list of mappings
  so that I can get to the things I need to change faster

  Background:
    Given I have logged in as an admin
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | http_status | path             | new_url                                 |
      | 410         | /about/corporate |                                         |
      | 301         | /about/branding  | http://gov.uk/branding                  |
      | 301         | /a               | http://gov.uk/directgov                 |
      | 410         | /notinfilter     |                                         |
    And I visit the path /sites/directgov/mappings

  Scenario: Filtering by start of path
    When I filter the path by /about
    Then the filter box should contain "/about"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  Scenario: Filtering by part of path
    When I filter the path by bout
    Then the filter box should contain "bout"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  Scenario: There are no matches
    When I filter the path by /is-not-there
    Then the filter box should contain "/is-not-there"
    And I should see "0 mappings"
    And I should see a link to remove the filter
