Feature: The tagging of mappings
  As a manager of mappings,
  I would like to tag mappings
  so that I can identify groups of mappings for specific needs or workflows

Scenario: Adding tags to a mapping
  Given I have logged in as an admin
  And a mapping exists for the site ukba
  When I edit that mapping
  And I associate the tags "fee, fi, FO" with the mapping
  And I save the mapping
  Then I should see "Mapping saved"
  And I should see the tags "fee, fi, fo"

Scenario: Adding tags when bulk adding mappings
  Given I have logged in as an admin
  And a site ukba exists with these tagged mappings:
  | path  | tags     |
  | /1    | fee, fum |
  | /2    | fi, fum  |
  | /3    | fo, fum  |
  When I add multiple paths with tags "fee, fi, FO" and continue
  Then the page title should be "Confirm new mappings"
  And I should see the tags "fee, fi, fo"
  When I choose "Overwrite existing mappings"
  And I save the mappings
  Then I should see that all were tagged "fee, fi, fo"
  And the mappings should all have the tags "fee, fi, fo, fum"




