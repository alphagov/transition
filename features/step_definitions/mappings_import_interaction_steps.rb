When(/^I go to import some mappings$/) do
  steps %{
    And I click the first link called "import from a spreadsheet"
  }
end

When(/^I submit the form with valid CSV$/) do
  raw_csv = <<-HEREDOC.strip_heredoc
                        old url,new url
                        /redirect-me,https://www.gov.uk/new
                        /archive-me,TNA
                        /i-dont-know-what-i-am,
                      HEREDOC
  fill_in 'import_batch_raw_csv', with: raw_csv
  click_button 'Continue'
end
