require 'spec_helper'

describe 'HostsPresenter' do
  let!(:site)   { create :site }
  let!(:host_b) { create :host, site: site }
  let!(:host_c) { create :host, site: site }

  describe '#as_hash' do
    subject(:presented_hosts) { HostsPresenter.new(Host.includes(:site)).as_hash }

    its([:results])        { should_not be_empty }
    its([:total])          { should     be(3) }
    its([:_response_info]) { should_not be_empty }

    describe '#as_hash results' do
      subject(:results) { HostsPresenter.new(Host.includes(:site)).as_hash[:results] }

      it 'contains the number of hosts' do
        expect(results.count).to be(3)
      end
    end
  end
end
