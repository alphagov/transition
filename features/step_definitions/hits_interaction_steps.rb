When(/^I click on the link to check the mapping for the top hit/) do
  click_link "", href: site_mapping_find_path(@site, path: "/A", return_path: site_hits_path(@site))
end

When(/^I filter by the date period "([^"]*)"$/) do |period_title|
  within ".hits-time-period" do
    click_link(period_title)
  end
end

When(/^I click a point for the date 18\/10\/12$/) do
  # Note: this doesn't really click a point. That's very hard to set up. We just visit the
  # same place clicking a point would have gone. I hope that's alright for you.
  visit "#{current_path}?period=20121018"
end

When(/^I visit universal analytics$/) do
  visit hits_path
end
