require 'google/apis/drive_v2'

module Transition
  module Google
    class APIClient
      def self.analytics_client!(scope = 'https://www.googleapis.com/auth/analytics.readonly')
        key     = ::Google::APIClient::KeyUtils.load_from_pkcs12('config/ga_key.p12', 'notasecret')
        secrets = JSON.parse(File.read('config/ga_client_secrets.json'))['web']

        client = Google::Apis::DriveV2::DriveService.new(
          application_name: 'Transition Tools',
          application_version: '1.0'
        )

        client.authorization = Signet::OAuth2::Client.new(
          token_credential_uri: secrets['token_uri'],
          audience: secrets['token_uri'],
          scope: scope,
          issuer: secrets['client_email'],
          signing_key: key)
        client.authorization.fetch_access_token!
      end
    end
  end
end
