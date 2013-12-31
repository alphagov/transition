require 'spec_helper'
require 'transition/import/site_transition_status'

describe Transition::Import::SiteTransitionStatus do
  describe '#from_hosts!' do
    subject { site.transition_status }

    before do
      site.hosts << hosts
      Transition::Import::SiteTransitionStatus.from_hosts!(site.hosts)
      site.reload
    end

    context 'with no hosts pointing to us' do
      let(:site) { create :site }
      let(:hosts) { [] }

      it { should eql('pre-transition') }
    end

    context 'with one host pointing to us and one not' do
      let(:site) { create :site }
      let(:host2) { create :host, cname: 'redirector-cdn.production.govuk.service.gov.uk' }
      let(:hosts) { [host2] }

      it { should eql('live') }
    end

    context 'when the site has been given indeterminate status' do
      let(:site) { create :site, transition_status: 'indeterminate' }

      context 'still with no hosts pointing to us' do
        let(:hosts) { [] }

        it { should eql('indeterminate') }
      end

      context 'when a host now points to us' do
        let(:host2) { create :host, cname: 'redirector-cdn.production.govuk.service.gov.uk' }
        let(:hosts) { [host2] }

        it { should eql('live') }
      end
    end
  end
end
