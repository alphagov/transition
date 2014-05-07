require 'spec_helper'

describe Host do
  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe 'validations' do
    describe 'validations which don\'t depend on aka?' do
      # Validation calls aka? when checking canonical_host_id, and will raise
      # an error on a nil hostname before validation finishes. This means that
      # to test validations which aren't dependent on aka? (for hostname in
      # particular) we need to stub aka? to see that validation actually working.
      before do
        subject.stub(:aka?).and_return(false)
      end

      it { should validate_presence_of(:hostname) }
      it { should validate_presence_of(:site) }
    end

    describe 'canonical_host_id' do
      context 'if not aka but has canonical_host_id' do
        subject(:host) { build :host, hostname: 'foo.gov.uk', canonical_host_id: 1 }

        its(:valid?) { should be_false }
        it 'should have an error for canonical_host_id' do
          host.errors_on(:canonical_host_id).should include('must be blank for a non-aka host')
        end
      end

      context 'if aka but has no canonical_host_id' do
        subject(:host) { build :host, hostname: 'aka-foo.gov.uk' }

        its(:valid?) { should be_false }
        it 'should have an error for canonical_host_id' do
          host.errors_on(:canonical_host_id).should include('can\'t be blank for an aka host')
        end
      end
    end

    describe 'hostnames' do
      subject(:host) { build :host, hostname: 'rarfoo.gov.uk/foo/' }

      its(:valid?) { should be_false }
      it 'should have an error for invalid hostname' do
        host.errors_on(:hostname).should include('is an invalid hostname')
      end
    end
  end

  describe 'scopes' do
    describe 'excluding_aka' do
      let(:site) { create(:site_without_host) }

      before do
        create(:host, :with_its_aka_host, site: site, hostname: 'www.foo.com')
        create(:host, :with_its_aka_host, site: site, hostname: 'foo.com')
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
