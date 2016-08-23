Feature: The tagging of mappings
  As a manager of mappings,
  I would like to tag mappings
  so that I can identify groups of mappings for specific needs or workflows

Scenario: Adding tags to a mapping
  Given I have logged in as a GDS Editor
  And a mapping exists for the site ukba
  When I edit that mapping
  And I associate the tags "fee, fi, FO" with the mapping
  And I save the mapping
  Then I should see "Mapping saved"
  And the mapping should have the tags "fee, fi, fo"
  When I edit that mapping
  Then I should see the tags "fee, fi, fo"

Scenario: Adding tags when bulk adding mappings
  Given I have logged in as a GDS Editor
  And a site "ukba" exists with these tagged mappings:
  | path  | tags     |
  | /1    | fee, fum |
  | /2    | fi, fum  |
  | /3    | fo, fum  |
  When I add multiple paths with tags "fee, fi, FO" and continue
  Then the page title should be "Confirm new mappings"
  And I should see the tags "fee, fi, FO"
  When I choose "Overwrite existing mappings"
  And I save the mappings
  Then I should see that all were tagged "fee, fi, FO"
  And the mappings should all have the tags "fee, fi, fo, fum"

Scenario: Bulk adding tags to existing mappings
  Given I have logged in as a GDS Editor
  And a site "ukba" exists with these tagged mappings:
  | path  | tags             |
  | /1    | fee, fum, fiddle |
  | /2    | fi, fum          |
  | /3    | fo, fum          |
  When I select the first two mappings and go to tag them
  Then the page title should be "Tag mappings"
  And I should see only the common tags "fum"
  When I delete "fum" and tag the mappings "fee, fo"
  Then I should see that 2 were tagged "fee, fo"
  And mapping 1 should have the tags "fee, fo, fiddle" but not "fum"
  And mapping 2 should have the tags "fee, fi, fo" but not "fum"
  And mapping 3 should have the tags "fo, fum"

@javascript
Scenario: Bulk adding tags to existing mappings (JS)
  Given I have logged in as a GDS Editor
  And a site "ukba" exists with these tagged mappings:
  | path  | tags             |
  | /1    | fee, fum, fiddle |
  | /2    | fi, fum          |
  | /3    | fo, fum          |
  When I select the first two mappings and go to tag them
  Then I should see "Tag mappings" in the modal window
  And I should see only the common tags "fum"
  When I delete "fum" and tag the mappings "fee, fo"
  Then I should see that 2 were tagged "fee, fo"
  And mapping 1 should have the tags "fee, fo, fiddle" but not "fum"
  And mapping 2 should have the tags "fee, fi, fo" but not "fum"
  And mapping 3 should have the tags "fo, fum"
  And I should see an open modal window
  And I should see a table with 2 saved mappings in the modal
  And an automatic analytics event with "bulk-edit-tag" will fire

@javascript
Scenario: Autocompleting popular tags
  Given I have logged in as a GDS Editor
  And a site "foo" exists with these tagged mappings:
  | path  | tags              |
  | /1    | from another site |
  And a site "ukba" exists with these tagged mappings:
  | path  | tags             |
  | /1    | fee, fum, fiddle |
  | /2    | fi, fum          |
  | /3    | fo, fox, fum     |
  | /4    | fo, fox, fum     |
  | /4    | fo, fox, fum     |
  When I select the first two mappings and go to tag them
  Then I should see "Tag mappings" in the modal window
  And I should see only the common tags "fum"
  When I type "f" in the tags box
  Then I should see "fo" available for selection
  And I should see "fox" available for selection
  And I should not see "from another site" available for selection
  But I should not see "fum" available for selection as it's already selected
