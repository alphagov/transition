require 'spec_helper'

describe WhitelistedHost do
  describe 'validations' do
    it { should validate_presence_of(:hostname) }

    describe 'hostname' do
      subject(:whitelisted_host) { build(:whitelisted_host, hostname: 'a.gov.uk/') }

      its(:valid?) { should be_false }
      it 'should have an error for invalid hostname' do
        whitelisted_host.errors_on(:hostname).should include('is an invalid hostname')
      end
    end
  end
end
