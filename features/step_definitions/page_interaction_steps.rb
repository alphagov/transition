When(/^I click the (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  click_link link_title
end

When(/^I click the "([^"]+)" button$/) do |title|
  click_button title
end

When(/^I click the first (?:link|tab)(?: called)? "([^"]+)"$/) do |link_title|
  first(:link, link_title).click
end

When(/^I click the first tag(?: called)? "([^"]+)"$/) do |tag|
  page.find("a.tag", text: tag, match: :first).click
end

When(/^I save my changes$/) do
  click_button "Save"
end

When(/^I go to page ([0-9]+)$/) do |page|
  first(:link, page).click
end
