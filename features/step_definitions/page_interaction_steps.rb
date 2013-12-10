When(/^I click the (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I submit the form with the "([^"]+)" button$/) do |button_text|
  click_button button_text
end

When(/^I go to page ([0-9]+)$/) do |page|
  first(:link, page).click
end
