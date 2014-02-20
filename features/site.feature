Feature: The site dashboard
  As a new manager of mappings,
  I would like to see a site dashboard that gives me a clear understanding of
    what I can do in the app and how I should do it
  so that I can manage mappings without creating errors

Scenario: Visit a post-transition site's page
  Given I have logged in as an admin
  Given the date is 29/11/12
  And www.attorney-general.gov.uk site with abbr ago launches on 13/12/12 with the following aliases:
    | alias                     |
    | www.lslo.gov.uk           |
    | www.ago.gov.uk            |
  When I visit this site page
  Then I should see the header "www.attorney-general.gov.uk"
  And I should see a big message that this site is pre-transition
  And I should see a big number "14 days until transition"
  And I should see the date of the site's transition
  And I should be able to edit the site's mappings
  And I should be able to view the site's analytics
  And I should see the site's configuration including all host aliases
  And I should see a link to the side by side browser

Scenario: Visit a pre-transition site's page
  Given I have logged in as an admin
  Given the date is 15/12/12
  And www.attorney-general.gov.uk site with abbr ago launched on 13/12/12 with the following aliases:
    | alias                     |
  When I visit this site page
  Then I should see a big message that this site is live
  And I should see a big number "2 days since transition"
  And I should see the date of the site's transition

Scenario: Mappings by tag
  Given I have logged in as an admin
  And a site ukba exists with these tagged mappings:
  | path  | tags                          |
  | /1    | 1, 2, 3, 4, 5, 6, 7, 8 ,9, 10 |
  | /2    | 1, 2, 3, 4, 5, 6, 7, 8 ,9, 10 |
  | /3    | 12, 13, 14                    |
  When I visit this site page
  Then I should see "Mappings by tag"
  And I should see the top 10 most used tags "1, 2, 3, 4, 5, 6, 7, 8, 9, 10"

Scenario: I belong to a different organisation
  Given I have logged in as a member of DCLG
  And www.attorney-general.gov.uk site with abbr ago launched on 13/12/12 with the following aliases:
    | alias                     |
  When I visit this site page
  Then I should be able to view the site's mappings
  But I should not be able to edit the site's mappings

@allow-rescue
Scenario: Visit the page of an non-existent site
  Given I have logged in as an admin
  When I visit the path /sites/not_a_site
  Then the HTTP status should be 'Not Found'
  And I should see "Page could not be found"
  And I should see a link to "GOV.UK Transition"
