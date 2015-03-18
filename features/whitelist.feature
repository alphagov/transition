Feature: Whitelist
  As a Transition Admin,
  I would like to see a whitelist of sites
  So that I can see which sites we're redirecting to outside of .gov.uk, .mod.uk or .nhs.uk

  Scenario: Visit the whitelist page as an admin
    Given I have logged in as an admin
    When I visit the whitelist page
    Then I should see the header "Redirection whitelist"

  Scenario: Visit the whitelist page as a GDS Editor
    Given I have logged in as a GDS Editor
    When I visit the whitelist page
    Then I should be redirected to the homepage
