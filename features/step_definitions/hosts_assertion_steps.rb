Then(/^the status in the response body should be "(.*)"$/) do |status|
  parsed_response = JSON.parse(page.body)
  expect(parsed_response["_response_info"]["status"]).to eql(status)
end
