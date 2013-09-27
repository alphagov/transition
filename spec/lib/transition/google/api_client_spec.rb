require 'spec_helper'
require 'transition/google/api_client'

describe Transition::Google::APIClient do
  before :all do
    @client = Transition::Google::APIClient.analytics_client!
  end

  # Remove config.filter_run_excluding :external_api => true from spec_helper.rb to run.
  # Checks that a connection to GA is possible with key and secrets in config/ga
  describe '.analytics_client!', external_api: true do
    it 'is a Google::APIClient' do
      @client.should be_a(Google::APIClient)
    end

    it 'has a token that is a non-zero length string' do
      @client.authorization.access_token.tap do |token|
        token.should be_a String
        token.length.should > 0
      end
    end
  end
end
