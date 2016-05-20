Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :zendesk, ENV['ZD_CLIENT'], ENV['ZD_SECRET'], client_options: {
    site: ENV['ZD_HOST']
  }, scope: 'read'
end
