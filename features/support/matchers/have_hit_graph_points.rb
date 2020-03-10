RSpec::Matchers.define :have_hit_graph_points do |count|
  def last_data_table(page)
    page.evaluate_script("GOVUK.Hits.lastDataTable()")
  end

  match do |page|
    expect(last_data_table(page)["rows"].length).to eql(count)
  end

  failure_message do |page|
    "expected hits graph to have #{count} points, #{last_data_table(page)['rows'].length} were found"
  end
end
