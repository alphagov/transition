When(/^I click the (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I go to page ([0-9]+)$/) do |page|
  first(:link, page).click
end
