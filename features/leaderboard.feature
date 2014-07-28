Feature: Leaderboard
  As a Transition user
  I would like to see an inverse leaderboard of departments
  So that I can see which department has the highest number of erroring mappings
  So that departments can be inspired to be lower down the list by fixing their mappings

  Scenario: Visit the leaderboard page
  Given I have logged in as a GDS Editor
  When I visit the leaderboard page
  Then I should see the header "Department leaderboard"
