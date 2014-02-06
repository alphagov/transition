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

Scenario: I belong to a different organisation
  Given I have logged in as a member of DCLG
  And www.attorney-general.gov.uk site with abbr ago launched on 13/12/12 with the following aliases:
    | alias                     |
  When I visit this site page
  Then I should be able to view the site's mappings
  But I should not be able to edit the site's mappings
