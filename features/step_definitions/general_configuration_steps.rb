When(/^the mappings page size is ([0-9]+)$/) do |page_number|
  Mapping.class_eval do
    paginates_per page_number.to_i
  end
end
