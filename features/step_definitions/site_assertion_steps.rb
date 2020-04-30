Then(/^I should see a big message that this site is (.*)$/) do |status|
  expect(page).to have_selector(".highlight-#{status}", text: status.capitalize)
end

Then(/^I should see a big number "(\d+) days (.*)"$/) do |days, message|
  within ".days-from-launch" do
    expect(page).to have_selector(".big-number", text: "#{days} days")
    expect(page).to have_content(message)
  end
end

Then(/^I should not see a link to view the site's mappings$/) do
  expect(page).not_to have_selector(".list-group-item-heading", text: "Mappings")
  expect(page).not_to have_link("a", href: site_mappings_path(@site))
end

Then(/^I should be able to view the site's analytics$/) do
  within ".performance" do
    expect(page).to have_selector(".list-group-item-heading", text: "Analytics")
    expect(page).to have_link("a", href: summary_site_hits_path(@site))
  end
end

Then(/^I should be able to edit the site's mappings$/) do
  within ".mappings" do
    expect(page).to have_selector(".list-group-item-heading", text: "Mappings")
    expect(page).to have_link("a", href: site_mappings_path(@site))
    expect(page).to have_selector(".list-group-item-heading", text: "Add mappings")
    expect(page).to have_link("a", href: new_site_bulk_add_batch_path(@site))
  end
end

Then(/^I should not be able to edit the site's mappings$/) do
  within ".mappings" do
    expect(page).not_to have_selector(".list-group-item-heading", text: "Add mappings")
    expect(page).not_to have_link("a", href: new_site_bulk_add_batch_path(@site))
  end
end

Then(/^I should see the site's configuration including all host aliases$/) do
  within ".configuration" do
    expected_definitions = {
      "New homepage" => "https://www.gov.uk/government/organisations/attorney-generals-office",
      "Significant query parameters" => "None",
      "The National Archive (TNA) timestamp" => "None",
    }

    expected_definitions.each_pair do |dt, dd|
      expect(page).to have_selector("dt", text: dt)
      expect(page).to have_selector("dd", text: dd)
    end

    %w[www.attorney-general.gov.uk www.ago.gov.uk www.lslo.gov.uk].each do |hostname|
      expect(page).to have_selector(".host-aliases td", text: hostname)
    end
  end
end

Then(/^I should see the date of the site's transition$/) do
  expect(page).to have_content("13 December 2012")
end

Then(/^I should be able to view the site's mappings$/) do
  within ".mappings" do
    expect(page).to have_selector(".list-group-item-heading", text: "Mappings")
    expect(page).to have_link("a", href: site_mappings_path(@site))
  end
end

Then(/^I should see a link to the side by side browser$/) do
  expect(page).to have_selector('a[href*="www.attorney-general.gov.uk.side-by-side"]')
end

Then(/^I should not see a link to the side by side browser$/) do
  expect(page).to_not have_selector('a[href*="www.attorney-general.gov.uk.side-by-side"]')
end

Then(/^I should see the top (\d+) most used tags$/) do |count|
  expected_tags = (1..count.to_i).to_a.map(&:to_s)
  within(".tag-list") do
    expect(page).to have_selector(".tag", count: count)
    expected_tags.each do |tag|
      expect(page).to have_selector(".tag", text: tag)
    end
  end
end

Then(/^I should see the top (\d+) most used tags "([^"]*)"$/) do |count, tag_list|
  expected_tags = tag_list.split(",").map(&:strip)
  within(".tag-list") do
    expect(page).to have_selector(".tag", count: count)
    expected_tags.each do |tag|
      expect(page).to have_selector(".tag", text: tag)
    end
  end
end
