When(/^the (.*) page size is ([0-9]+)$/) do |class_name, page_number|
  klass = Object.const_get(class_name.singularize.capitalize)
  klass.class_eval do
    paginates_per page_number.to_i
  end
end
