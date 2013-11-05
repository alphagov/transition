Given(/^the (.*) page size is ([0-9]+)$/) do |class_name, page_number|
  klass = Object.const_get(class_name.singularize.capitalize)
  klass.class_eval do
    paginates_per page_number.to_i
  end
end

Given(%r(^the date is ([0-9]{2})/([0-9]{2})/([0-9]{2})$)) do |day, month, year|
  Timecop.travel Date.new(2000 + year.to_i, month.to_i, day.to_i)
end
