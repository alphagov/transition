When(/^I go to create a new mapping$/) do
  click_link 'Add mapping'
end

When(/^I make the mapping a redirect to (.*)$/) do |new_url|
  select 'Redirect', from: 'Type'
  fill_in 'Redirects to', with: new_url
end

When(/^I make the mapping an archive$/) do
  select 'Archive', from: 'Type'
end

When(/^I (save|create) the mapping$/) do |type|
  click_button type.titleize
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
  fill_in 'Filter by', with: path_contains
  click_button 'Filter'
end

When(/^I change the mapping's redirect to (.*)$/) do |value|
  fill_in 'Redirects to', with: value
  step 'I save the mapping'
end

When(/^I make the mapping a redirect from (.*) to (.*)$/) do |path, new_url|
  fill_in 'Old URL', with: path
  fill_in 'Redirects to', with: new_url
end

When(/^I enter an archive URL but then click "Cancel"$/) do
  fill_in 'Alternative national archive URL', with: 'anything'
  click_link 'Cancel'
end

When(/^I enter a new URL to redirect to$/) do
  fill_in 'Redirect to', with: 'https://www.gov.uk'
end
