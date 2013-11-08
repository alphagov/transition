require 'spec_helper'

describe 'HostPresenter' do
  describe '#as_hash' do
    let(:site) { create(:site_with_default_host) }
    let(:host) { site.hosts.first }
    subject { HostPresenter.new(host).as_hash }

    it 'should generate JSON' do
      expected = {
        hostname: host.hostname,
        managed_by_transition: site.managed_by_transition,
      }
      subject { should eql(expected) }
    end
  end
end
