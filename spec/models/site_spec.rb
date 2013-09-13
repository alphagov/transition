require 'spec_helper'

describe Site do
  describe 'relationships' do
    it { should belong_to(:organisation) }
    it { should have_many(:hosts) }
    it { should have_many(:mappings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:abbr) }
    it { should validate_uniqueness_of(:abbr) }
  end

  # given that hosts are site aliases
  describe '#default_host' do
    let(:hosts) { [create(:host), create(:host)] }
    subject(:site) do
      FactoryGirl.create(:site) do |site|
        site.hosts = hosts
      end
    end

    its(:default_host) { should eql(hosts.first) }
  end
end
