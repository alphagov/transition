# Co-operates with support/page_size_defaulter.rb
# This should be called no more than once per scenario
Given(/^the (.*) page size is ([0-9]+)$/) do |class_name, page_size|
  klass = Object.const_get(class_name.singularize.capitalize)
  if @klass_old_page_sizes && @klass_old_page_sizes[klass]
    raise ArgumentError, "Page size has already been set for #{klass} in current Scenario"
  end

  klass_old_page_sizes = @klass_old_page_sizes || {}

  klass.class_eval do
    klass_old_page_sizes[klass] = klass.default_per_page
    paginates_per page_size.to_i
  end

  @klass_old_page_sizes = klass_old_page_sizes
end

Given(%r(^the date is ([0-9]{2})/([0-9]{2})/([0-9]{2})$)) do |day, month, year|
  Timecop.travel Date.new(2000 + year.to_i, month.to_i, day.to_i)
end
