Given(/^I have logged in as a GDS Editor$/) do
  GDS::SSO.test_user = create(:gds_editor)
end

Given(/^I have logged in as an admin$/) do
  GDS::SSO.test_user = create(:admin)
end

Given(/^I have logged in as a member of DCLG$/) do
  dclg = create(:organisation,
                title: "Department for Communities and Local Government",
                abbreviation: "DCLG",
                whitehall_slug: "department-for-communities-and-local-government")

  GDS::SSO.test_user = create(:user, organisation_content_id: dclg.content_id)
end

Given(/^I log in as a SIRO$/) do
  GDS::SSO.test_user = create(:gds_editor)
end

Given(/^I have logged in as a GDS Editor called "([^"]*)"$/) do |name|
  GDS::SSO.test_user = create(:gds_editor, name: name)
end

Given(/^I have logged in as a member of another organisation$/) do
  GDS::SSO.test_user = create(:user, organisation_content_id: SecureRandom.uuid)
end
