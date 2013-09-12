Feature: View organisation
  As a GDS User
  I want to see all the sites that belong to an organisation on a page
  so that I can work on their mappings

  Scenario: Visit an organisation page
    Given I have logged in as a GDS user
    And there is an organisation named Ministry of funk abbreviated funk with these sites:
      | abbr | homepage                          |
      | awb  | http://average-white-band.gov.uk/ |
      | prl  | http://parliament.gov.uk/         |
    When I visit the path /organisations/funk
    Then I should see the header "Ministry of funk"
    And  I should see the header "Sites"
    And  I should see a link to the awb site's mappings
    And  I should see a link to the URL http://average-white-band.gov.uk/
    And  I should see a link to the prl site's mappings
    And  I should see a link to the URL http://parliament.gov.uk/
