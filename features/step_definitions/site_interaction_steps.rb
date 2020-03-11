When(/^I visit this site page$/) do
  visit site_path(@site)
end

When(/^I edit this site's transition date$/) do
  click_link "Edit date"
  select("2014", from: "site_launch_date_1i")
  select("September", from: "site_launch_date_2i")
  select("20", from: "site_launch_date_3i")
  click_button "Save"
end
