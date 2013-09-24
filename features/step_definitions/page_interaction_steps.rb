When(/^I click the (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I go to create a new mapping$/) do
  click_link 'New mapping'
end

When(/^I go to page ([0-9]+)$/) do |page|
  first(:link, page).click
end
                     ``
When(/^I make the mapping a redirect with a new URL of (.*)$/) do |new_url|
  select '301', from: 'HTTP Status'
  fill_in 'New URL', with: new_url
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

When(/^I click the first "(.*)" link in the history table$/) do |event_name|
  within '.versions' do
    first(:link, event_name).click
  end
end

When(/^I make the mapping a redirect from (.*) to (.*)$/) do |path, new_url|
  fill_in 'Path', with: path
  fill_in 'New URL', with: new_url
end
