require 'spec_helper'

describe Host do
  describe 'relationships' do
    it { should belong_to(:site) }
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
