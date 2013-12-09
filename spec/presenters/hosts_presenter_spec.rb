require 'spec_helper'

describe 'HostsPresenter' do
  let!(:site)   { create :site }
  let!(:host_b) { create :host, site: site }
  let!(:host_c) { create :host, site: site }

  describe '#as_hash' do
    subject(:presented_hosts) { HostsPresenter.new(Host.includes(:site)).as_hash }

    its([:results])        { should_not be_empty }
    its([:total])          { should     be(6) }
    its([:_response_info]) { should_not be_empty }

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

      describe 'the first host' do
        subject { results.first }
        its([:managed_by_transition]) { should be_true }
      end
    end
  end
end
