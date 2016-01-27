require 'spec_helper'
require 'transition/google/api_client'

describe Transition::Google::APIClient do
  before :all do
    @client = Transition::Google::APIClient.analytics_client!
  end

  # These specs don't run by default. Remove `config.filter_run_excluding :external_api => true to run them.
  # Checks that a connection to GA is possible with key and secrets in config/ga
  describe '.analytics_client!', external_api: true do
    it 'is a Google::APIClient' do
      expect(@client).to be_a(Google::APIClient)
    end

    it 'has a token that is a non-zero length string' do
      @client.authorization.access_token.tap do |token|
        expect(token).to be_a String
        expect(token.length).to be > 0
      end
    end
  end
end
