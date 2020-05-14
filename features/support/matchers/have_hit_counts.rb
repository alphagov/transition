RSpec::Matchers.define :have_hit_counts do |counts|
  include ActionView::Helpers::NumberHelper
  include MappingsHelper

  match do |page|
    unless counts.is_a?(Array)
      raise ArgumentError,
            "counts should be an array (got a #{counts.class})"
    end

    within "table.mappings tbody" do
      expect(page).to have_selector("tr", count: counts.length)

      counts.each_with_index do |count, index|
        if @_total
          expected = friendly_hit_percentage((count.to_f / @_total) * 100)
          span_class = "hit-percentage"
        else
          expected = number_with_delimiter(count.to_s)
          span_class = "hit-count"
        end
        expect(page).to have_selector(
          "tr:nth-child(#{index + 1}) td.mapping-hits-column span.#{span_class}",
          text: Regexp.new("^#{expected}$"),
        )
      end
    end
  end

  chain :as_percentages_of do |total|
    @_total = total
  end
end
