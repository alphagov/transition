Feature: List organisations
  As a GDS User,
  I would like to see a list of organisations
  so that I can get to the mappings for a site

  Background:
    Given I have logged in as a GDS Editor
    And there are these organisations with sites:
      | whitehall_slug | title                                          |
      | bis            | Department for Business, Innovation and Skills |
      | fco            | Foreign Office                                 |
    And there are these organisations without sites:
      | whitehall_slug  | title                         |
      | ukti            | UK Trade & Industry           |
      | go-science      | Government Office for Science |
    And go-science is an extra organisation of bis.gov.uk

  Scenario: Visit the list page
    When I visit the home page
    Then I should see "Stub User"
    And I should see the header "Organisations"
    And I should see an organisations table with 3 rows
    And I should see a link to the organisation bis
    And I should see a link to the organisation fco
    And I should see a link to the organisation go-science
    But I should not see a link to the organisation ukti

  @javascript
  Scenario: See the "jump to a site or mapping" link with Javascript enabled
    When I visit the home page
    Then I should see a link to "jump to a site or mapping"
    When I click the link "jump to a site or mapping"
    Then I should see "Go to site or mapping" in a modal window

  @javascript
  Scenario: Filter the list page
    When I visit the home page
    And I filter organisations by "foreign"
    Then I should see an organisations table with 1 row
    And I should see a link to the organisation fco
    But I should not see a link to the organisation bis
