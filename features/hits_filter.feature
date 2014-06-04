Feature: Filter hits
  As a user
  I want to filter the list of hits
  So that I can see traffic for subsections or individual pages

  Background:
    Given I have logged in as a GDS Editor
    And the date is 19/10/12
    And these hits exist for the Attorney General's office site:
      | http_status | path             | hit_on   | count |
      | 200         | /about/corporate | 16/10/12 | 100   |
      | 200         | /about/branding  | 16/10/12 | 100   |
      | 200         | /notinfilter     | 16/10/12 | 100   |

    When I visit the associated site
    And I click the link "Analytics"
    And I click the link "All hits"

  Scenario: Filtering by path without JavaScript
    When I click the link "Filter hits"
    And I filter the path by /about
    Then the filter box should contain "/about"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  @javascript
  Scenario: Filtering by start of path
    When I open the "Path" filter and filter by "/about"
    Then I should see "Filtered analytics"
    And the "Path" filter should be visible and contain "/about"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"
    When I remove the filter "Path"
    Then I should see "/notinfilter"

  Scenario: Filtering by part of path
    When I click the link "Filter hits"
    And I filter the path by bout
    Then the filter box should contain "bout"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  Scenario: There are no matches
    When I click the link "Filter hits"
    And I filter the path by /is-not-there
    Then the filter box should contain "/is-not-there"
    And I should see "0 paths"
