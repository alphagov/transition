Feature: View hosts
  As a configurer of other services relating to the transition process
  I want to see all the hosts as JSON
  so that I can easily use that information in scripts

  Background:
    Given there are 2 sites with hosts

  Scenario: Visit the hosts API
    When I visit the path /hosts
    Then I should see JSON
    And the status in the response body should be "ok"
