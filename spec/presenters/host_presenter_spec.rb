require 'spec_helper'

describe 'HostPresenter' do
  describe '#as_hash' do
    let(:site) { create(:site) }
    let(:host) { site.default_host }

    subject { HostPresenter.new(host).as_hash }

    it { should have_key(:hostname) }
    its([:hostname]) { should eql(host.hostname) }

    it { should have_key(:managed_by_transition) }
    its([:managed_by_transition]) { should be_true }
  end
end
