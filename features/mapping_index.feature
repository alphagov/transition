Feature: Mappings index
  As a GDS'er with an interest in the performance of mappings,
  I would like to see a list of mappings for a site
  so that I know there are some

  Scenario: Looking at a default list of mappings
    Given I have logged in as a GDS Editor
    And a site has lots of mappings
    When I visit the site's mappings
    Then I should not see a column with hits information

  @allow-rescue
  Scenario: Visit the mappings index page for an non-existent site
    Given I have logged in as a GDS Editor
    And I visit the path /sites/not_a_site/mappings/
    Then I should see our custom 404 page

  Scenario: Visit the mappings index page for a globally redirected site
    Given I have logged in as a GDS Editor
    And a site moj_academy exists
    And the site is globally redirected
    When I visit the path /sites/moj_academy/mappings/
    Then I should be redirected to the site dashboard
    And I should see "This site has been entirely redirected."

  Scenario: Visit the mappings index page for a globally archived site
    Given I have logged in as a GDS Editor
    And a site defra_etr exists
    And the site is globally archived
    When I visit the path /sites/defra_etr/mappings/
    Then I should be redirected to the site dashboard
    And I should see "This site has been entirely archived."
