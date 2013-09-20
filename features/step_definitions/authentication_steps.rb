Given(/^I have logged in as a GDS user$/) do
  GDS::SSO.test_user = create(:user)
end

Given(/^I log in as a SIRO$/) do
  GDS::SSO.test_user = create(:user)
end

Given(/^I have logged in as a GDS user called "([^"]*)"$/) do |name|
  GDS::SSO.test_user = create(:user, name: name)
end
