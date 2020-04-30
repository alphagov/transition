Then(/^I should be on the (.*) mappings page$/) do |site_abbr|
  site = Site.find_by!(abbr: site_abbr)
  i_should_be_on_the_path site_mappings_path(site)
end

Then(/^I should see how many of each type of mapping will be created$/) do
  steps %(
    Then I should see "Create 1 new redirect"
    Then I should see "Create 0 new archives"
    Then I should see "Create 1 new unresolved mapping"
  )
end

Then(/^I should see how many archive mappings will be created and how many have custom URLs$/) do
  steps %{
    Then I should see "Create 3 new archives (2 with custom URLs)"
  }
end

Then(/^I should see how many mappings will be overwritten$/) do
  steps %(
    Then I should see "Overwrite 1 existing mapping"
  )
end

Then(/^I should not see how many mappings will be overwritten$/) do
  steps %(
    Then I should not see "Overwrite 1 existing mapping"
  )
end

Then(/^I should see a preview of my small batch of mappings$/) do
  steps %(
    Then I should see "Preview mappings"
  )
  within "table.mappings tbody" do
    expect(page).to have_selector("tr:nth-child(1) td.mapping-type-redirect", text: "Redirect")
    expect(page).to have_selector("tr:nth-child(2) td.mapping-type-archive", text: "Archive")
    expect(page).to have_selector("tr:nth-child(3) td.mapping-type-unresolved", text: "Archive")

    expect(page).to have_selector("tr:nth-child(1) td:last-child", text: "/redirect-me")
    expect(page).to have_selector("tr:nth-child(1) td:last-child", text: "will redirect to https://www.gov.uk/new")
    expect(page).to have_selector("tr:nth-child(2) td:last-child", text: "/archive-me")
    expect(page).to have_selector("tr:nth-child(3) td:last-child", text: "/i-dont-know-what-i-am")
  end
end

Then(/^I should see a preview of my large batch of mappings$/) do
  steps %{
    Then I should see "Preview mappings (20 of 21)"
  }
  within "table.mappings tbody" do
    expect(page).to have_selector("tr .breakable", count: 20)
  end
end

Then(/^I should see prominent progress of the import$/) do
  steps %(
    Then I should see "0 of 21 mappings imported" in a modal window
  )
end

Then(/^I should see less prominent progress of the import$/) do
  steps %(
    And I should see a flash message "0 of 21 mappings imported"
  )
end

Then(/^we have recorded analytics that show that import with overwrite existing was used$/) do
  steps %(
    And an automatic analytics event with "import-overwrite-existing" will fire
  )
end
