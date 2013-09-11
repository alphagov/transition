When(/^there are (\d+) organisations$/) do |n|
  n.to_i.times { FactoryGirl.create(:organisation) }
end