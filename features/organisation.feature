Feature: View organisation
  As a GDS User
  I want to see all the sites that belong to an organisation on a page
  so that I can work on their mappings

  Scenario: Visit an organisation page
    Given I have logged in as an admin
    And there is a bis organisation named UK Atomic Energy Authority abbreviated ukaea with these sites:
      | abbr       | homepage                                                               |
      | bis_ukaea  | https://www.gov.uk/government/organisations/uk-atomic-energy-authority |
    When I visit the path /organisations/ukaea
    Then I should see the header "UK Atomic Energy Authority"
    And I should see that this organisation is an executive non-departmental public body of its parent
    And I should see links to all this organisation's sites
    And I should see all the old homepages for the sites of the given organisation

  Scenario: I can edit an organisation's mappings
    Given I have logged in as a member of DCLG
    When I visit the path /organisations/department-for-communities-and-local-government
    Then I should see "You have permission to edit site mappings for Department for Communities and Local Government"

  Scenario: Organisation page with sites in each transition state
    Given I have logged in as an admin
    And there is an organisation with the whitehall_slug "ukaea"
    And the organisation has a site with a host with a GOV.UK cname
    And the organisation has a site with a host with a third-party cname
    And the organisation has a site with a special redirect strategy of "via_aka"
    And the organisation has a site with a special redirect strategy of "supplier"
    When I visit the path /organisations/ukaea
    Then I should see "Live"
    And I should see "Pre-transition"
    And I should see "Indeterminate"
    And there should be a tooltip which includes "external supplier"
    And there should be a tooltip which includes "partially redirected"

  @allow-rescue
  Scenario: Visit the page of an non-existent organisation
    Given I have logged in as an admin
    When I visit the path /organisations/not-an-org
    Then I should see our custom 404 page
