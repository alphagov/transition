Feature: Mappings priority
  As a user
  I want to see how important mappings are whilst I'm editing them
  So that I don't have to go back and forth between analytics and mappings and continually interpret hits data
  And so that I'm not confused by the seemingly inconsistent nature of hits

  Background:
    Given I have logged in as an admin

  Scenario: There are lots of hits for a site's hosts
    Given a site has lots of mappings and lots of hits
    When I visit the site's mappings
    And I sort the mappings by hits
    Then I should see a column with hits information
    And the cells should have hit counts
    And the cells should have percentages

  @javascript
  Scenario: There are lots of hits for a site's hosts
    Given a site has lots of mappings and lots of hits
    When I visit the site's mappings
    And I sort the mappings by hits
    Then I should see a column with hits information
    And the cells should have hit counts
    And the cells should have percentages
    When I remove all sorting and filtering
    Then I should not see a column with hits information

  Scenario: A site has mappings but no hits
    Given a site has lots of mappings and no hits
    When I visit the site's mappings
    Then I should not be able to sort the mappings by hits

  @javascript
  Scenario: A site has mappings but no hits
    Given a site has lots of mappings and no hits
    When I visit the site's mappings
    Then I should not be able to sort the mappings by hits
