When(/^I filter organisations by "(.*?)"$/) do |text|
  fill_in 'Filter organisations', with: text
end
