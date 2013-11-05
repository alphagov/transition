When(/^I go to create a new mapping$/) do
  click_link 'Add mapping'
end

When(/^I make the mapping a redirect with a new URL of (.*)$/) do |new_url|
  select '301', from: 'HTTP Status'
  fill_in 'New URL', with: new_url
end

When(/^I make the mapping an archive$/) do
  select '410', from: 'HTTP Status'
end

When(/^I save the mapping$/) do
  click_button 'Save'
end

When(/^I go to edit the first mapping$/) do
  click_link 'Edit'
end

When(/^I filter the path by ([^"]*)$/) do |path_contains|
  fill_in 'Filter by path', with: path_contains
  click_button 'Filter'
end

When(/^I change the mapping's (.*) to (.*)$/) do |field_name, value|
  fill_in field_name, with: value
  step 'I save the mapping'
end

When(/^I make the mapping a redirect from (.*) to (.*)$/) do |path, new_url|
  fill_in 'Path', with: path
  fill_in 'New URL', with: new_url
end
