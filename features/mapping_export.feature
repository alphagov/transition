Feature: Export mappings
  As an admin user,
  I would like to export mappings
  So that I can filter and search in ways not supported by the app
  So that I can edit mappings in ways not supported by the app and then import them

  Background:
    Given I have logged in as an admin
    And there is a site called directgov belonging to an organisation directgov with these mappings:
      | type     | path             | new_url                   | tags |
      | archive  | /about/corporate |                           |      |
      | redirect | /about/branding  | http://a.gov.uk/branding  |      |
      | redirect | /another         | http://a.gov.uk/directgov |      |
    And I visit the path /sites/directgov/mappings

  Scenario: Exporting mappings
    When I export the mappings
    Then I should get a CSV containing exactly 3 mappings

  Scenario: Exporting filtered mappings
    When I click the link "Filter mappings"
    And I filter the path by about
    And I export the mappings
    Then I should get a CSV containing exactly 2 mappings
