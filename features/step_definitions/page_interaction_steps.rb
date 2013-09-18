When(/^I click the link(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I go to page ([0-9]+)$/) do |page|
  first(:link, page).click
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
