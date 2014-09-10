When(/^I visit this site page$/) do
  visit site_path(@site)
end

And(/^I enter "(.*?)" into the launch date box and click save$/) do |date|
  fill_in 'New transition date', with: date
  click_button 'Save'
end
