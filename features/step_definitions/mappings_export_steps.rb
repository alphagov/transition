When(/^I export the mappings$/) do
  click_link "Export CSV", match: :first
end

Then(/^I should get a CSV containing exactly (\d+) mappings$/) do |mappings_count|
  csv = CSV.parse(page.body)
  expect(csv.first).to eql(["Old URL", "Type", "New URL", "Archive URL", "Suggested URL"])
  row_count = csv.size - 1 # exclude the header row
  expect(row_count).to eql(mappings_count.to_i)
end
