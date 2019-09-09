# Workaround for broken zendesk/oauth gem
# See https://github.com/jonasoberschweiber/omniauth-zendesk-oauth2/issues/3
module OmniAuth
  module Strategies
    class Zendesk < OmniAuth::Strategies::OAuth2
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :zendesk, ENV['ZD_CLIENT'], ENV['ZD_SECRET'], client_options: {
    site: ENV['ZD_HOST']
  }, scope: 'read'
end
