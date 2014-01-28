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
  step 'I should see "Mapping saved"'
end

Then(/^the filter box should contain "([^"]*)"$/) do |path|
  expect(page).to have_field('Original path', with: path)
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

Then(/^I should see a highlighted "(.*?)" label and field$/) do |label|
  expect(page).to have_selector('.field_with_errors label', text: label)

  label = find('label', text: label)
  expect(page).to have_selector(".field_with_errors *[name='#{label['for']}']")
end

Then(/^I should see options to ignore or overwrite the existing mappings$/) do
  expect(page).to have_field('Ignore existing mappings', type: 'radio')
  expect(page).to have_field('Overwrite existing mappings', type: 'radio')
end

Then(/^I should see that the mappings will redirect to "(.*?)"$/) do |new_url|
  step "I should see \"Redirect paths to #{new_url}\""
end

Then(/^I should see the canonicalized paths "(.*?)"$/) do |paths|
  paths.split(', ').each do |path|
    expect(page).to have_link(path)
  end
end

Then(/^I should see the tags "([^"]*)"$/) do |tag_list|
  expect(page).to have_field('Tags', with: tag_list)
end

Then(/^the mappings should be saved with tags "([^"]*)"$/) do |tag_list|
  # Temporary assertion - the flash message will move to tag display in the table
  within '.alert-success' do
    expect(page).to have_content("3 mappings created and tagged with \"#{tag_list}\". 0 mappings updated.")
  end
end
