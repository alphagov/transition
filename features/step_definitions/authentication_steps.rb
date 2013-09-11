Given(/^I have logged in as a GDS user$/) do
  GDS::SSO.test_user = FactoryGirl.create(:user)
end
