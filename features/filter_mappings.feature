@wip
Feature: Filter mappings
  As a GDS User with an interest in the quality of mappings,
  I want to filter the list of mappings
  so that I can get to the things I need to change faster 

  Background:
    Given I have logged in as a GDS user
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | http_status | path             | new_url                                 |
      | 410         | /about/corporate |                                         |
      | 301         | /about/branding  | http://gov.uk/branding                  |
      | 301         | /                | http://gov.uk/bis                       |
      | 410         | /notinfilter     |                                         |

  Scenario: Filtering by start of path
    When I filter the path by /about
    Then I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  Scenario: Filtering by part of path
    When I filter the path by bout
    Then I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

