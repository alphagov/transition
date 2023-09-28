Feature: The site dashboard
  As a new manager of mappings,
  I would like to see a site dashboard that gives me a clear understanding of
    what I can do in the app and how I should do it
  so that I can manage mappings without creating errors

Scenario: Visit a pre-transition site's page
  Given I have logged in as a GDS Editor
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

Scenario: Visit a post-transition site's page
  Given I have logged in as a GDS Editor
  Given the date is 15/12/12
  And www.attorney-general.gov.uk site with abbr ago launched on 13/12/12 with the following aliases:
    | alias                     |
  When I visit this site page
  Then I should see a big message that this site is live
  And I should see a big number "2 days since transition"
  And I should see the date of the site's transition

Scenario: Mappings by tag
  Given I have logged in as a GDS Editor
  And a site "ukba" exists with mappings with lots of tags
  When I visit this site page
  Then I should see "Mappings by tag"
  And I should see the top 10 most used tags

Scenario: I belong to a different organisation
  Given I have logged in as a member of DCLG
  And www.attorney-general.gov.uk site with abbr ago launched on 13/12/12 with the following aliases:
    | alias                     |
  When I visit this site page
  Then I should be able to view the site's mappings
  But I should not be able to edit the site's mappings

Scenario: Visit a globally redirected site's page
  Given I have logged in as a GDS Editor
  And a site moj_academy exists
  And the site is globally redirected
  When I visit this site page
  Then I should see "All paths from moj_academy.gov.uk"
  Then I should see "redirect to"
  And I should not see a link to view the site's mappings

Scenario: Visit the page for a site globally redirected, where the path is appended
  Given I have logged in as a GDS Editor
  And a site moj_academy exists
  And the site is globally redirected with the path appended
  When I visit this site page
  Then I should see "All paths from moj_academy.gov.uk"
  Then I should see "redirect to"
  And I should see "The path the user visited is appended to the destination"
  And I should not see a link to view the site's mappings

Scenario: Visit a globally archived site's page
  Given I have logged in as a GDS Editor
  And a site defra_etr exists
  And the site is globally archived
  When I visit this site page
  Then I should see "All paths from defra_etr.gov.uk"
  Then I should see "have been archived"
  And I should not see a link to view the site's mappings

@allow-rescue
Scenario: Visit the page of an non-existent site
  Given I have logged in as a GDS Editor
  When I visit the path /sites/not_a_site
  Then I should see our custom 404 page

@javascript
Scenario: Jumping to a site
  Given I have logged in as a member of DCLG
  And a site bis exists
  When I visit the home page
  And I jump to the site or mapping "http://bis.gov.uk"
  Then I should see the header "bis.gov.uk"

@javascript
Scenario: Jumping to a site appending a / but nothing after it
  Given I have logged in as a member of DCLG
  And a site bis exists
  When I visit the home page
  And I jump to the site or mapping "http://bis.gov.uk/"
  Then I should see the header "bis.gov.uk"

@javascript
Scenario: Jumping to a non-existent site
  Given I have logged in as a member of DCLG
  When I visit the home page
  And I jump to the site or mapping "http://not-a-site.gov.uk"
  Then I should see the header "Unknown site"

Scenario: Creating a site
  Given I have logged in as a Site Manager
  And there are these organisations without sites:
    | whitehall_slug  | title                         |
    | ukti            | UK Trade & Industry           |
    | go-science      | Government Office for Science |
  When I visit the page for the UK Trade & Industry organisation
  And I click the link "Add a transition site"
  Then I should be on the new transition site page for the UK Trade & Industry organisation
  When I fill in the new transition site fields
  And I save my changes
  Then I should be redirected to the new site

Scenario: Editing a site's transition date as a GDS Editor
  Given I have logged in as a GDS Editor
  And the date is 29/11/19
  And a site bis exists
  And I visit this site page
  When I edit this site's transition date
  Then I should be redirected to the site dashboard
  And I should see "Transition date updated"
  And I should see "20 September 2014"

Scenario: Editing a site's transition date as a non-GDS Editor
  Given I have logged in as a member of DCLG
  And a site dclg exists
  And I visit this site page
  Then I should not see "Edit date"
  When I visit the path /sites/dclg/edit_date
  Then I should be redirected to the site dashboard
  And I should see "Only GDS Editors can access that."

Scenario: Deleting a site as a Site Manager
  Given I have logged in as a Site Manager
  And a site bis exists
  And I visit this site page
  When I delete this site
  Then I should be prompted to confirm the deletion
  When I fail to confirm the deletion
  Then I should see "The confirmation did not match"
  And I should be prompted to confirm the deletion
  When I confirm the deletion
  Then I should be redirected to the organisation dashboard
  And I should see the deletion confirmation message

Scenario: Deleting a site as a non-Site Manager
  Given I have logged in as a member of DCLG
  And a site dclg exists
  And I visit this site page
  Then I should not see "Delete"
  When I visit the path /sites/dclg/confirm_destroy
  Then I should be redirected to the site dashboard
  And I should see "Only Site Managers can access that."
