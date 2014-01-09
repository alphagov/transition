Then(/^I should be returned to the mappings list for (.*)$/) do |site_abbr|
  expect(current_path).to eql(site_mappings_path(site_abbr))
end

Then(/^I should still be editing a mapping$/) do
  step 'I should see "Edit mapping"'
end

Then(/^I should be editing the mapping for "([^"]*)"$/) do |path|
  expect(page).to have_selector("form a[href*='#{path}']")
end

Then(/^I should be returned to the edit mapping page with a success message$/) do
  step 'I should see "Edit mapping"'
  page.should satisfy {|page| page.has_content?('Mapping created') or page.has_content?('Mapping saved')}
end

Then(/^the filter box should contain "([^"]*)"$/) do |path|
  expect(page).to have_field('Filter by', with: path)
end

Then(/^I should see a link to remove the filter$/) do
  expect(page).to have_link('Remove filter')
end

Then(/^I should see no history$/) do
  expect(page).not_to have_link('History')
end

Then(/^I should see that (.*) was changed from (.*) to (.*)$/) do |field_name, old_value, new_value|
  within '.versions' do
    expect(page).to have_content(field_name)
    expect(page).to have_content(old_value)
    expect(page).to have_content(new_value)
  end
end

Then(/^I should see redirect fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).to have_selector('.js-for-redirect')
  end
end

Then(/^I should not see redirect fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).not_to have_selector('.js-for-redirect')
  end
end

Then(/^I should see archive fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).to have_selector('.js-for-archive')
  end
end

Then(/^I should not see archive fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).not_to have_selector('.js-for-archive')
  end
end

Then(/^I should see the national archive link replaced with an alternative national archive field$/) do
  expect(page).to have_selector('#mapping_archive_url')
  expect(page).not_to have_selector('a[href="#add-alternative-url"]')
end

Then(/^I should see the national archive link again$/) do
  expect(page).not_to have_selector('#mapping_archive_url')
  expect(page).to have_selector('a[href="#add-alternative-url"]')
end

Then(/^the archive URL field should be empty$/) do
  field_labeled('Alternative national archive URL').value.should be_empty
end

Then(/^I should see a form that contains my selection$/) do
  steps %{
    And I should see "/a"
    And I should see "/about/branding"
    But I should not see "/about/corporate"
  }
end

Then(/^I should see a form that contains my selection within the modal$/) do
  steps %{
    And I should see "/a" in the modal window
    And I should see "/about/branding" in the modal window
    But I should not see "/about/corporate" in the modal window
  }
end

Then(/^I should see the link replaced with a suggested URL field$/) do
  expect(page).to have_selector('#mapping_suggested_url')
  expect(page).not_to have_selector('a[href="#suggest-url"]')
end

Then(/^I should see a "Redirect to" input$/) do
  expect(page).to have_selector('label', text: 'Redirect to')
end

Then(/^I should not see a "Redirect to" input$/) do
  expect(page).not_to have_selector('label', text: 'Redirect to')
end
