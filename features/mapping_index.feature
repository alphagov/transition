Feature: Mappings index
  As a GDS'er with an interest in the performance of mappings,
  I would like to see a list of mappings for a site
  so that I know there are some

  @allow-rescue
  Scenario: Visit the mappings index page for an non-existent site
    Given I have logged in as an admin
    And I visit the path /sites/not_a_site/mappings/
    Then I should see our custom 404 page
