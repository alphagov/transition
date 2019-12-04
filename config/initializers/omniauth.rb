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
  provider :auth0,
    ENV['AUTH0_CLIENT_ID'],
    ENV['AUTH0_CLIENT_SECRET'],
    ENV['AUTH0_DOMAIN'],
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid email'
    }
end
