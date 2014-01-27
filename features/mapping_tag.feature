Feature: The tagging of mappings
  As a manager of mappings,
  I would like to tag mappings
  so that I can identify groups of mappings for specific needs or workflows

@wip
Scenario: Adding tags to a mapping
  Given I have logged in as an admin
  And a mapping exists for the site ukba
  When I edit that mapping
  And I associate the tags "fee, fi, fo" with the mapping
  And I save the mapping
  Then I should see "Mapping saved"
  And I should see the tags "fee, fi, fo"


