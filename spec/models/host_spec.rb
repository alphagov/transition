require 'spec_helper'

describe Host do
  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe 'scopes' do
    describe 'excluding_aka' do
      let(:site) { create(:site_without_host) }

      before do
        create(:host, site: site, hostname: 'www.foo.com')
        create(:host, site: site, hostname: 'foo.com')
        create(:host, site: site, hostname: 'aka.foo.com')
        create(:host, site: site, hostname: 'aka-foo.com')
      end

      subject { site.hosts.excluding_aka.pluck(:hostname) }
      it { should eql(['www.foo.com', 'foo.com']) }
    end
  end

  describe '#aka?' do
    subject { host.aka? }

    context 'a www host' do
      let(:host) { build(:host, hostname: 'www.foo.com') }
      it { should be_false }
    end

    context 'a non-www host' do
      let(:host) { build(:host, hostname: 'foo.com') }
      it { should be_false }
    end

    context 'an aka. host' do
      let(:host) { build(:host, hostname: 'aka.foo.com') }
      it { should be_true }
    end

    context 'an aka- host' do
      let(:host) { build(:host, hostname: 'aka-foo.com') }
      it { should be_true }
    end
  end

  describe '#aka_hostname' do
    subject { host.aka_hostname }

    context "when the hostname has no www" do
      let(:host) { build(:host, hostname: 'foo.com') }
      it { should eql('aka-foo.com') }
    end

    context "when the hostname has www on the front" do
      let(:host) { build(:host, hostname: 'www.foo.com') }
      it { should eql('aka.foo.com') }
    end

    context "when the hostname has www2 on the front" do
      let(:host) { build(:host, hostname: 'www2.lowpay.gov.uk') }
      it { should eql('aka-www2.lowpay.gov.uk') }
    end
  end

  describe '#redirected_by_gds?' do
    context 'standard CDN CNAME' do
      subject { build(:host, cname: 'redirector-cdn.production.govuk.service.gov.uk') }
      its(:redirected_by_gds?) { should be_true }
    end

    context 'businesslink events CDN CNAME' do
      subject { build(:host, cname: 'redirector-cdn-ssl-events-businesslink.production.govuk.service.gov.uk') }
      its(:redirected_by_gds?) { should be_true }
    end

    context 'external CNAME' do
      subject { build(:host, cname: 'bis-tms-101-L01.eduserv.org.uk') }
      its(:redirected_by_gds?) { should be_false }
    end

    context 'no CNAME (A-record only)' do
      subject { build(:host, cname: nil) }
      its(:redirected_by_gds?) { should be_false }
    end
  end
end
