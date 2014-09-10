When(/^I visit this site page$/) do
  visit site_path(@site)
end

And(/^I enter "(.*?)", "(.*?)", "(.*?)" into the launch date select boxes and click save$/) do |day, month, year|
  select(year, from: 'site_launch_date_1i')
  select(month, from: 'site_launch_date_2i')
  select(day, from: 'site_launch_date_3i')
  click_button 'Save'
end
