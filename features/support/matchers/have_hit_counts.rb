RSpec::Matchers.define :have_hit_counts do |counts|
  match do |page|
    raise ArgumentError,
          "counts should be an array (got a #{counts.class})" unless counts.is_a?(Array)

    within 'table.mappings tbody' do
      expect(page).to have_selector('tr', count: counts.length)

      counts.each_with_index do |count, index|
        expect(page).to have_selector("tr:nth-child(#{index + 1}) td.mapping-hits-column span.hit-count",
                                      text: Regexp.new("^#{count.to_s}$"))
      end
    end
  end
end
