GdsApi.configure do |config|
  # Never return nil when a server responds with 404 or 410.
  config.always_raise_for_not_found = true

  # Return a hash, not an OpenStruct from a request.
  config.hash_response_for_requests = true
end
