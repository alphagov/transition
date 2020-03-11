When(/^I filter organisations by "(.*?)"$/) do |text|
  fill_in "Filter organisations", with: text
end

When(/^I filter sites by "(.*?)"$/) do |text|
  fill_in "Filter sites", with: text
end
