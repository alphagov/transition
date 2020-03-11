Then(/^I should see a list of organisations sorted by decreasing error count$/) do
  within ".leaderboard" do
    expect(page).to have_selector("tbody > tr:nth-child(1) > td:last-child", text: /1,240$/)
    expect(page).to have_selector("tbody > tr:nth-child(2) > td:last-child", text: /99$/)
    expect(page).to have_selector("tbody > tr:nth-child(3) > td:last-child", text: "")
  end
end
