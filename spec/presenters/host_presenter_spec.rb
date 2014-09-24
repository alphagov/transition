require 'spec_helper'

describe 'HostPresenter' do
  describe '#as_hash' do
    let(:site) { create(:site) }
    let(:host) { site.default_host }

    subject { HostPresenter.new(host).as_hash }

    it { should have_key(:hostname) }
    its([:hostname]) { should eql(host.hostname) }
  end
end
