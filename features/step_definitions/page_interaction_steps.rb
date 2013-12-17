When(/^I click the (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I click the first (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  first(:link, link_title).click
end

When(/^I click the (?:link|tab)(?: called)? "([^"]+)" within "([^"]+)"$/) do |link_title, selector|
  within selector do
    click_link link_title
  end
end

When(/^I submit the form with the first "([^"]+)" button$/) do |button_text|
  first(:button, button_text).click
end

When(/^I submit the form with the "([^"]+)" button$/) do |button_text|
  click_button button_text
end

When(/^I go to page ([0-9]+)$/) do |page|
  first(:link, page).click
end
