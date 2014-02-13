When(/^I go to create some mappings$/) do
  steps %{
    And I click the first link called "Add mappings"
  }
end

When(/^I visit the site\'s mappings$/) do
  visit site_mappings_path(@site)
end

When(/^I make the mapping a redirect to (.*)$/) do |new_url|
  select 'Redirect', from: 'Type'
  fill_in 'Redirects to', with: new_url
end

When(/^I make the mapping an archive$/) do
  select 'Archive', from: 'Type'
end

When(/^I continue?$/) do
  click_button 'Continue'
end

When(/^I save the mappings?$/) do
  click_button 'Save'
end

When(/^I go to edit the first mapping$/) do
  click_link 'Edit'
end

When(/^I select the first two mappings$/) do
  find(:css, ".mappings tbody tr:first-child input").set(true)
  find(:css, ".mappings tbody tr:first-child + tr input").set(true)
end

When (/^I go to edit the selected mappings$/) do
  click_button "Edit selected"
end

When(/^I select "Archive"$/) do
  choose 'Archive'
end

When(/^I filter the path by ([^"]*)$/) do |path_contains|
  fill_in 'Original path', with: path_contains
  click_button 'Filter'
end

When(/^I change the mapping's redirect to (.*)$/) do |value|
  fill_in 'Redirects to', with: value
  step 'I save the mapping'
end

When(/^I make the new mapping paths "(.*)" redirect to (.*)$/) do |paths, new_url|
  fill_in 'Old URLs', with: paths.gsub(/, /, "\n")
  fill_in 'Redirect to', with: new_url
end

When(/^I enter an archive URL but then click "Cancel"$/) do
  fill_in 'Alternative national archive URL', with: 'anything'
  click_link 'Cancel'
end

When(/^I enter a new URL to redirect to$/) do
  fill_in 'Redirect to', with: 'https://www.gov.uk'
end

When(/^I edit that mapping$/) do
  visit edit_site_mapping_path(@site, @mapping) 
end

When(/^I associate the tags "([^"]*)" with the mappings?$/) do |comma_separated_tags|
  fill_in 'Tags', with: comma_separated_tags
end


When(/^I add multiple paths with tags "([^"]*)" and continue$/) do |tag_list|
  visit new_multiple_site_mappings_path(@site)

  step 'I make the new mapping paths "/1, /2, /3" redirect to www.gov.uk/organisations/ukba'
  step "I associate the tags \"#{tag_list}\" with the mappings"
  step 'I continue'
end

When(/^I choose "([^"]*)"$/) do |radio_label|
  choose(radio_label)
end

When(/^I remove the tag "([^"]*)"$/) do |tag|
  page.find('.filtered-tags a', text: tag).click
end

When(/^I select the first two mappings and go to tag them$/) do
  visit site_mappings_path(@site)

  step 'I select the first two mappings'

  if @_javascript
    first(:link, 'Tag').click
  else
    choose 'Tag'
    click_button 'Edit selected'
  end
end

When(/^I delete "(?:[^"]*)" and tag the mappings "([^"]*)"$/) do |tag_list|
  step "I tag the mappings \"#{tag_list}\""
end

 When(/^I tag the mappings "([^"]*)"$/) do |tag_list|
  if @_javascript
    find(:xpath, '//input[contains(@class, "select2-offscreen")]').set(tag_list)
  else
    fill_in 'Tags', with: tag_list
  end
  click_button 'Save'
end


When(/^I type "([^"]*)" in the tags box$/) do |letters|
  fill_in 'Tags', with: letters
end
