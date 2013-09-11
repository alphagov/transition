When(/^I visit the home page$/) do
  visit '/'
end

When(/^I visit the path (.*)$/) do |path|
  visit path
end
