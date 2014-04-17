Feature: Mappings index
  As a GDS'er with an interest in the performance of mappings,
  I would like to see a list of mappings for a site
  so that I know there are some

  @allow-rescue
  Scenario: Visit the mappings index page for an non-existent site
    Given I have logged in as an admin
    And I visit the path /sites/not_a_site/mappings/
    Then I should see our custom 404 page

  Scenario: Visit the mappings index page for a globally redirected site
    Given I have logged in as an admin
    And a site moj_academy exists
    And the site is globally redirected
    When I visit the path /sites/moj_academy/mappings/
    Then I should be redirected to the path "/sites/moj_academy"
    And I should see "This site has been entirely redirected or archived."

  Scenario: Visit the mappings index page for a globally archived site
    Given I have logged in as an admin
    And a site defra_etr exists
    And the site is globally archived
    When I visit the path /sites/defra_etr/mappings/
    Then I should be redirected to the path "/sites/defra_etr"
    And I should see "This site has been entirely redirected or archived."
