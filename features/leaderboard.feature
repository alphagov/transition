Feature: Leaderboard
  As a Transition user
  I would like to see an inverse leaderboard of departments
  So that I can see which department has the highest number of erroring mappings
  So that departments can be inspired to be lower down the list by fixing their mappings

  Scenario: Visit the leaderboard page
  Given I have logged in as a GDS Editor
  And there are errors for one organisation but not for another
  When I visit the leaderboard page
  Then I should see a list of organisations sorted by decreasing error count

  Scenario: Visit the leaderboard page without GDS Editor permission
  Given I have logged in as a member of DCLG
  When I visit the leaderboard page
  Then I should be redirected to the homepage
  And I should see "Only GDS Editors can access the leaderboard."
