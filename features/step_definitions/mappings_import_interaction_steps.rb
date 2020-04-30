When(/^I import a large valid CSV for bis$/) do
  steps %(
    And a site bis exists
    And I visit the path /sites/bis
    And I go to import some mappings
    Then I should see "http://bis.gov.uk"
  )
  i_submit_a_form_with_a_large_valid_csv
end

When(/^I go to import some mappings$/) do
  steps %(
    And I click the first link called "import from a spreadsheet"
  )
end

When(/^I submit the form with a small valid CSV$/) do
  raw_csv = <<-CSV.strip_heredoc
                        old url,new url
                        /redirect-me,https://www.gov.uk/new
                        /archive-me,TNA
                        /i-dont-know-what-i-am,
  CSV
  fill_in "import_batch_raw_csv", with: raw_csv
  click_button "Continue"
end

When(/^I submit the form with a small CSV of archive mappings$/) do
  raw_csv = <<-CSV.strip_heredoc
                        old url,new url
                        /archive-me,TNA
                        /archive-me-as-well,http://webarchive.nationalarchives.gov.uk/20120816224015/http://bis.gov.uk/about
                        /dont-forget-me,http://webarchive.nationalarchives.gov.uk/20120816224015/http://bis.gov.uk/faq
  CSV
  fill_in "import_batch_raw_csv", with: raw_csv
  click_button "Continue"
end

When(/^I navigate away to the bis mappings page$/) do
  visit(site_mappings_path("bis"))
end

When(/^I confirm the preview$/) do
  click_button("Import")
end

And(/^I should see that my unresolved mapping is there$/) do
  steps %(
    And I should see "/i-dont-know-what-i-am" in a modal window
  )
end
