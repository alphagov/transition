Feature: Filter mappings
  As a GDS User with an interest in the quality of mappings,
  I want to filter the list of mappings
  so that I can get to the things I need to change faster

  Background:
    Given I have logged in as a GDS Editor
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | type     | path             | new_url                 | tags             |
      | archive  | /about/corporate |                         | fee, fum, fiddle |
      | redirect | /about/branding  | http://gov.uk/branding  | fi, fum          |
      | redirect | /another         | http://gov.uk/directgov | fo, fiddle       |
      | archive  | /notinfilter     |                         |                  |
    And I visit the path /sites/directgov/mappings

  Scenario: Filtering by path without JavaScript
    When I click the link "Filter mappings"
    And I filter the path by /about
    Then the filter box should contain "/about"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  @javascript
  Scenario: Filtering by start of path
    When I open the "Path" filter and filter by "/about"
    Then I should see "Filtered mappings"
    And the "Path" filter should be visible and contain "/about"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"
    When I remove the filter "Path"
    Then I should see "/notinfilter"

  @javascript
  Scenario: Filtering by new url
    When I open the "New URL" filter and filter by "gov.uk"
    Then I should see "Filtered mappings"
    And the "New URL" filter should be visible and contain "gov.uk"
    And I should see "/about/branding"
    And I should see "/another"
    But I should not see "/about/corporate"
    When I remove the filter "New URL"
    Then I should see "/notinfilter"

  @javascript
  Scenario: Filtering by multiple properies
    When I open the "New URL" filter and filter by "gov.uk"
    And I open the "Path" filter and filter by "/a"
    Then I should see "Filtered mappings"
    And the "New URL" filter should be visible and contain "gov.uk"
    And the "Path" filter should be visible and contain "/a"
    And I should see "/about/branding"
    But I should not see "/about/corporate"
    When I remove the filter "New URL"
    And I open the tag filter and click the tag "fiddle"
    Then the "Path" filter should be visible and contain "/a"
    And the tag filter should be visible with the tag "fiddle"
    And I should see "/about/corporate"
    But I should not see "/about/branding"
    When I open the "Type" filter and select "Redirect"
    Then I should see "/another"
    But I should not see "/about/corporate"

  Scenario: Filtering by part of path
    When I click the link "Filter mappings"
    And I filter the path by bout
    Then the filter box should contain "bout"
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/notinfilter"

  Scenario: There are no matches
    When I click the link "Filter mappings"
    And I filter the path by /is-not-there
    Then the filter box should contain "/is-not-there"
    And I should see "0 mappings"

  Scenario: Filtering by clicking tags
    Given I have logged in as a GDS Editor
    And I click the first tag "fum"
    Then I should see mappings tagged with "fum"
    And I should see the highlighted tag "fum"
    And I should see a link to remove the tag "fum"
    When I click the first tag "fiddle"
    Then I should see mappings tagged with "fum" and "fiddle"
    And I should see the highlighted tags "fum, fiddle"
    And I should see a link to remove the tags "fum, fiddle"
    When I remove the tag "fiddle"
    Then I should see mappings tagged with "fum"

  @javascript
  Scenario: Filtering by tag
    When I open the "Tag" filter
    Then I should see the most popular tags for this site
    When I click the tag filter "fum"
    Then I should see "Filtered mappings"
    And the tag filter should be visible with the tag "fum"
    And I should see mappings tagged with "fum"

  @javascript
  Scenario: Filtering by multiple tags
    When I open the tag filter and click the tag "fum"
    And I open the tag filter and click the tag "fee"
    Then the tag filter should be visible with the tags "fee, fum"
    And I should see "/about/corporate"
    But I should not see "/about/branding"

  @javascript
  Scenario: Filtering by type
    When I open the "Type" filter and select "Redirect"
    Then I should see "Filtered mappings"
    And I should see "/about/branding"
    And I should see "/another"
    But I should not see "/notinfilter"
    When I open the "Redirects" filter and select "Archive"
    And I should see "/about/corporate"
    And I should see "/notinfilter"
    But I should not see "/another"
    When I open the "Archives" filter and select "All types"
    Then I should not see "Filtered mappings"

  @javascript
  Scenario: Filtering by type and New URL
    When I open the "New URL" filter and filter by "gov.uk"
    And I open the "Type" filter and select "Archive"
    Then I should see a warning about an incompatible filter
