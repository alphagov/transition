When(/^I click the link(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I change the mapping to a (\d+) with a new URL of (.*)$/) do |status, new_url|
  select status, from: 'HTTP Status'
  fill_in 'New URL', with: new_url
end

When(/^I save the mapping$/) do
  click_button 'Save'
end

When(/^I edit the first mapping$/) do
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
