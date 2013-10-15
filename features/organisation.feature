Feature: View organisation
  As a GDS User
  I want to see all the sites that belong to an organisation on a page
  so that I can work on their mappings

  Scenario: Visit an organisation page
    Given I have logged in as a GDS user
    And there is a bis organisation named UK Atomic Energy Authority abbreviated ukaea with these sites:
      | abbr       | homepage                                                               |
      | bis_ukaea  | https://www.gov.uk/government/organisations/uk-atomic-energy-authority |
    When I visit the path /organisations/ukaea
    Then I should see the header "UK Atomic Energy Authority"
    And I should see that this organisation works with its parent
    And I should see links to all this organisation's sites and homepages
