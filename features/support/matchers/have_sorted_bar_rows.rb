RSpec::Matchers.define :have_sorted_bar_rows do |count|
  match do |page|
    unless @_status
      raise ".for_status expected. Call like expect(page).to have_sorted_bar_rows(11).for_status(401)"
    end

    expect(page).to have_selector("tbody tr", count: count)
    expect(page).to have_selector(".bar-chart-row-#{@_status}", count: count)
    counts = page.all(:css, "td.count").map { |node| node.text.to_i }

    expect(counts).to be_sorted.descending
  end

  chain :for_status do |status|
    @_status = status
  end
end
