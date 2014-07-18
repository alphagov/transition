When(/^I go to import some mappings$/) do
  steps %{
    And I click the first link called "import from a spreadsheet"
  }
end

When(/^I submit the form with a small valid CSV$/) do
  raw_csv = <<-CSV.strip_heredoc
                        old url,new url
                        /redirect-me,https://www.gov.uk/new
                        /archive-me,TNA
                        /i-dont-know-what-i-am,
                      CSV
  fill_in 'import_batch_raw_csv', with: raw_csv
  click_button 'Continue'
end

When(/^I submit the form with a large valid CSV$/) do
  raw_csv = <<-CSV.strip_heredoc
                        old url,new url
                        /1
                        /2
                        /3
                        /4
                        /5
                        /6
                        /7
                        /8
                        /9
                        /10
                        /11
                        /12
                        /13
                        /14
                        /15
                        /16
                        /17
                        /18
                        /19
                        /20
                        /21
                      CSV
  fill_in 'import_batch_raw_csv', with: raw_csv
  click_button 'Continue'
end
