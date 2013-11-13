require 'spec_helper'

describe 'HostsPresenter' do
  let(:site)   { create :site_with_default_host }
  let(:host_b) { create :host, site: site }
  let(:host_c) { create :host, site: site }

  before do
    site.should be_persisted
    host_b.should be_persisted
    host_c.should be_persisted
  end

  describe '#as_hash' do
    subject(:presented_hosts) { HostsPresenter.new(Host.includes(:site)).as_hash }

    it 'contains results, total and response info' do
      [:results, :total, :_response_info].each do |key|
        presented_hosts { should have_key(key) }
      end
    end

    describe '#as_hash results' do
      subject(:results) { HostsPresenter.new(Host.includes(:site)).as_hash[:results] }

      it 'contains twice the number of hosts (to include aka hostnames)' do
        expect(results.count).to be(6)
      end

      it 'contains the actual and aka hostnames for each stored host' do
        hostnames = results[0..1].map { |h| h[:hostname] }
        expected_hostnames =
          [
            site.default_host.hostname,
            site.default_host.aka_hostname,
          ]
        expect(hostnames).to eql(expected_hostnames)
      end

      it 'provides the hostname and managed_by_transition for a host' do
        first_host = results.first
        expect(first_host).to have_key(:hostname)
        expect(first_host).to have_key(:managed_by_transition)
      end
    end
  end
end
