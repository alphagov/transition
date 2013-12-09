require 'spec_helper'

describe 'HostPresenter' do
  describe '#as_hash' do
    let(:site) { create(:site) }
    let(:host) { site.default_host }

    subject { HostPresenter.new(host).as_hash }

    it { should have_key(:hostname) }

    context 'when use_aka_hostname is false (by default)' do
      subject { HostPresenter.new(host).as_hash }
      its([:hostname]) { should eql(host.hostname) }
    end

    context 'when use_aka_hostname is true' do
      subject { HostPresenter.new(host, use_aka_hostname: true).as_hash }
      its([:hostname]) { should eql(host.aka_hostname) }
    end

    it { should have_key(:managed_by_transition) }
    its([:managed_by_transition]) { should be_true }
  end
end
