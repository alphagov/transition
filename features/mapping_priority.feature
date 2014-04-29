Feature: Mappings priority
  As a user
  I want to see how important mappings are whilst I'm editing them
  So that I don't have to go back and forth between analytics and mappings and continually interpret hits data
  And so that I'm not confused by the seemingly inconsistent nature of hits

  Background:
    Given I have logged in as an admin
    And a site has lots of mappings and lots of hits
    When I visit the site's mappings

  Scenario: There are lots of hits for a site's hosts
    When I sort the mappings by traffic
    Then I should see a column with traffic information
    And the cells should have hit counts
    And the cells should have percentages

  @javascript
  Scenario: There are lots of hits for a site's hosts
    When I sort the mappings by traffic
    Then I should see a column with traffic information
    And the cells should have hit counts
    And the cells should have percentages
