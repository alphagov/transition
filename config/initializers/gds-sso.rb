GDS::SSO.config do |config|
  config.user_model   = 'User'
  config.oauth_id     = ENV['SIGNON_OAUTH_ID']
  config.oauth_secret = ENV['SIGNON_OAUTH_SECRET']
  config.oauth_root_url = Plek.current.find("signon")
end
