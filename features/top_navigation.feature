Feature: Top Navigation

  Scenario: User has an organisation
    Given I have logged in as a member of DCLG
    When I visit the home page
    Then I should see a link to "Department for Communities and Local Government (DCLG)" in the header

  @allow-rescue
  Scenario: Visit a non-existent page, matching no routes
    Given I have logged in as an admin
    When I visit the path /totes/no/routes/here
    Then I should see our custom 404 page
