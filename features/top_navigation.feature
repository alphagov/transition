Feature: Top Navigation

  Scenario: User has an organisation
    Given I have logged in as a member of DCLG
    When I visit the home page
    Then I should see a link to "Department for Communities and Local Government (DCLG)" in the header
