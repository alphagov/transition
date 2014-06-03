require 'spec_helper'

describe WhitelistedHost do
  describe 'validations' do
    it { should validate_presence_of(:hostname) }
    it { should validate_uniqueness_of(:hostname).with_message('is already in the list') }

    describe 'hostname' do
      context 'is invalid' do
        subject(:whitelisted_host) { build(:whitelisted_host, hostname: 'a.gov.uk/') }

        its(:valid?) { should be_false }
        it 'should have an error for invalid hostname' do
          whitelisted_host.errors_on(:hostname).should include('is an invalid hostname')
        end
      end

      context 'is automatically allowed anyway' do
        subject(:whitelisted_host) { build(:whitelisted_host, hostname: 'a.gov.uk') }

        its(:valid?) { should be_false }
        it 'should have an error' do
          whitelisted_host.errors_on(:hostname).should include('cannot end in .gov.uk or .mod.uk - these are automatically whitelisted')
        end
      end
    end
  end
end
