Then(/^I should see all hits for the Attorney General's office in descending count order$/) do
  within '.hits' do
    counts = page.all(:css, 'td.count').map { |node| node.text.to_i }

    expect(counts).to be_sorted.descending
  end
end

Then(/^I should not see hits for the Cabinet Office site$/) do
  within '.hits' do
    expect(page).to_not have_content('/cabinetoffice')
  end
end

Then(/^the hits should be grouped by path and status$/) do
  within '.hits' do
    expect(page).to have_selector('tbody tr', count: 4)
    expect(page).to have_selector('tbody tr:first-child .count', text: '300')
  end
end

Then(/^the top hit should be represented by a 100% bar$/) do
  within '.hits' do
    expect(page).to have_selector('tbody tr:first-child .bar-chart-row[style*="width: 100"]')
  end
end

Then(/^subsequent hits should have smaller bars$/) do
  within '.hits' do
    expect(page).to have_selector('tbody tr:nth-child(2) .bar-chart-row[style*="width: 66.6"]')
  end
end

Then(/^each path should be a link to the real URL$/) do
  within '.hits' do
    anchors = page.all(:css, '.path a')
    expect(anchors).to have(4).links
  end
end

Then(/^I should see a section for the most common errors on the Attorney General's office$/) do
  expect(page).to have_selector('h2', text: 'Errors')
end

Then(/^I should see a section for the most common archives$/) do
  expect(page).to have_selector('h2', text: 'Archives')
end

Then(/^I should see a section for the most common redirects$/) do
  expect(page).to have_selector('h2', text: 'Redirects')
end

Then(/^I should see a section for the other hits, the most common miscellany$/) do
  expect(page).to have_selector('h2', text: 'Other')
end

Then(/^it should show only the top ten errors in descending count order$/) do
  within '.hits-errors' do
    expect(page).to have_sorted_bar_rows(10).for_status(404)
  end
end

Then(/^it should show only the top ten archives in descending count order$/) do
  within '.hits-archives' do
    expect(page).to have_sorted_bar_rows(10).for_status(410)
  end
end

Then(/^it should show only the top ten redirects in descending count order$/) do
  within '.hits-redirects' do
    expect(page).to have_sorted_bar_rows(10).for_status(301)
  end
end

Then(/^it should show only the top ten other hits in descending count order$/) do
  within '.hits-other' do
    expect(page).to have_sorted_bar_rows(10).for_status(200)
  end
end

Then(/^I should see all hits with an error status for the Attorney General's office in descending count order$/) do
  within '.hits' do
    expect(page).to have_sorted_bar_rows(11).for_status(404)
  end
end

Then(/^I should see all hits with an archive status for the Attorney General's office in descending count order$/) do
  within '.hits' do
    expect(page).to have_sorted_bar_rows(11).for_status(410)
  end
end

Then(/^I should see all hits with a redirect status for the Attorney General's office in descending count order$/) do
  within '.hits' do
    expect(page).to have_sorted_bar_rows(11).for_status(301)
  end
end

Then(/^I should see all hits with long tail statuses for the Attorney General's office in descending count order$/) do
  within '.hits' do
    expect(page).to have_sorted_bar_rows(11).for_status(200)
  end
end

Then(/^each hit should have a link to check its mapping$/) do
  within '.hits tbody' do
    page.all('tr').each do |row|
      path = row.find(:css, '.path').text
      mapping = row.find(:css, '.action')
      expect(mapping).to have_link('', href: site_mapping_find_path(@site, path: path))
    end
  end
end

Then(/^I should be on the new mapping page$/) do
  step 'I should see "New mapping"'
end

Then(/^the top hit's canonicalized path should already be in the form$/) do
  expect(find_field('Path').value).to eql('/a')
end

Then(/^an errors graph showing two dates and a red trend line$/) do

  result = page.evaluate_script('rawData')
  expect(result).to eql([["Date", "Errors"], ["2012-10-17", 200], ["2012-10-18", 810]])

  # Poltergeist doesnt correctly find content of SVG text elements
  # Use an SVG matcher instead of:
  # expect(page).to have_selector('text', text: 'Errors')
  expect(page).to have_svg_text('Errors')

  expect(page).to have_selector('path[stroke="#ee9999"]')
end
