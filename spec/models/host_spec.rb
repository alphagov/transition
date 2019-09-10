require 'rails_helper'

describe Host do
  describe 'relationships' do
    subject { build(:host) }
    it { is_expected.to belong_to(:site) }
  end

  describe 'validations' do
    describe 'validations which don\'t depend on aka?' do
      # Validation calls aka? when checking canonical_host_id, and will raise
      # an error on a nil hostname before validation finishes. This means that
      # to test validations which aren't dependent on aka? (for hostname in
      # particular) we need to stub aka? to see that validation actually working.
      before do
        allow(subject).to receive(:aka?).and_return(false)
      end

      it { is_expected.to validate_presence_of(:hostname) }
      it { is_expected.to validate_presence_of(:site) }
    end

    describe 'canonical_host_id' do
      context 'if not aka but has canonical_host_id' do
        subject(:host) { build :host, hostname: 'foo.gov.uk', canonical_host_id: 1 }

        describe '#valid?' do
          subject { super().valid? }
          it { is_expected.to be_falsey }
        end
        it 'should have an error for canonical_host_id' do
          expect(host.errors_on(:canonical_host_id)).to include('must be blank for a non-aka host')
        end
      end

      context 'if aka but has no canonical_host_id' do
        subject(:host) { build :host, hostname: 'aka-foo.gov.uk' }

        describe '#valid?' do
          subject { super().valid? }
          it { is_expected.to be_falsey }
        end
        it 'should have an error for canonical_host_id' do
          expect(host.errors_on(:canonical_host_id)).to include('can\'t be blank for an aka host')
        end
      end
    end

    describe 'hostnames' do
      context 'includes a path' do
        subject(:host) { build :host, hostname: 'rarfoo.gov.uk/foo/' }

        describe '#valid?' do
          subject { super().valid? }
          it { is_expected.to be_falsey }
        end
        it 'should have an error for invalid hostname' do
          expect(host.errors_on(:hostname)).to include('is an invalid hostname')
        end
      end

      context 'unparseable' do
        subject(:host) { build :host, hostname: 'a}b.com' }

        describe '#valid?' do
          subject { super().valid? }
          it { is_expected.to be_falsey }
        end
        it 'should have an error for invalid hostname' do
          expect(host.errors_on(:hostname)).to include('is an invalid hostname')
        end
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
      it { is_expected.to match_array(['www.foo.com', 'foo.com']) }
    end

    describe 'with_cname_or_ip_address' do
      before do
        create(:host, cname: nil, ip_address: "192.168.0.1")
        create(:host, cname: "foo.example.com", ip_address: nil)
        create(:host, cname: nil, ip_address: nil)
      end

      subject { Host.with_cname_or_ip_address.pluck(:cname, :ip_address) }
      it do
        is_expected.to contain_exactly(
          [nil, '192.168.0.1'],
          ['foo.example.com', nil]
        )
      end
    end
  end

  describe '#aka?' do
    subject { host.aka? }

    context 'a www host' do
      let(:host) { build(:host, hostname: 'www.foo.com') }
      it { is_expected.to be_falsey }
    end

    context 'a non-www host' do
      let(:host) { build(:host, hostname: 'foo.com') }
      it { is_expected.to be_falsey }
    end

    context 'an aka. host' do
      let(:host) { build(:host, hostname: 'aka.foo.com') }
      it { is_expected.to be_truthy }
    end

    context 'an aka- host' do
      let(:host) { build(:host, hostname: 'aka-foo.com') }
      it { is_expected.to be_truthy }
    end
  end

  describe '#aka_hostname' do
    subject { host.aka_hostname }

    context "when the hostname has no www" do
      let(:host) { build(:host, hostname: 'foo.com') }
      it { is_expected.to eql('aka-foo.com') }
    end

    context "when the hostname has www on the front" do
      let(:host) { build(:host, hostname: 'www.foo.com') }
      it { is_expected.to eql('aka.foo.com') }
    end

    context "when the hostname has www2 on the front" do
      let(:host) { build(:host, hostname: 'www2.lowpay.gov.uk') }
      it { is_expected.to eql('aka-www2.lowpay.gov.uk') }
    end
  end

  describe '#redirected_by_gds?' do
    context 'standard CDN CNAME' do
      subject { build(:host, cname: 'redirector-cdn.production.govuk.service.gov.uk') }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_truthy }
      end
    end

    context 'alternate CDN CNAME' do
      subject { build(:host, cname: 'bouncer-cdn.production.govuk.service.gov.uk') }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_truthy }
      end
    end

    context 'businesslink events CDN CNAME' do
      subject { build(:host, cname: 'redirector-cdn-ssl-events-businesslink.production.govuk.service.gov.uk') }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_truthy }
      end
    end

    context 'external CNAME' do
      subject { build(:host, cname: 'bis-tms-101-L01.eduserv.org.uk') }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_falsey }
      end
    end

    context 'no CNAME or A records' do
      subject { build(:host, cname: nil, ip_address: nil) }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_falsey }
      end
    end

    context 'IP pointing at a non-redirector EC2 box' do
      subject { build(:host, cname: nil, ip_address: '127.0.0.1') }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_falsey }
      end
    end

    context 'IP pointing at Bouncer' do
      subject { build(:host, cname: nil, ip_address: '151.101.0.204') }

      describe '#redirected_by_gds?' do
        subject { super().redirected_by_gds? }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'moving to a different site' do
    context 'there are related mappings, host_paths and hits' do
      let!(:site)          { create(:site, query_params: 'significant_on_first_site') }
      let!(:other_site)    { create(:site) }
      let!(:runaway_host)  { create(:host, site: site) }

      context 'mappings only on original site' do
        let!(:hit)           { create(:hit, path: '/some-path?significant_on_first_site=1', host: runaway_host) }
        let!(:mapping)       { create(:mapping, path: hit.path, site: site) }

        before do
          # Connect everything with the old hosts
          Transition::Import::HitsMappingsRelations.refresh!

          runaway_host.site = other_site
          runaway_host.save!
        end

        it 'clears relationships which no longer exist' do
          # This host_path and hit shouldn't be related to this mapping any more
          # because they are for a host which has moved to a different site.
          #
          # Potentially this mapping should be moved too, but we can't really tell,
          # so leave it behind. A mapping can always be created on the new site.

          expect(hit.reload.mapping).to eql(nil)

          host_path = runaway_host.host_paths.find_by_path(hit.path)
          expect(host_path.mapping).to eql(nil)
        end
      end

      context 'mappings for the same paths exist on the new site' do
        let!(:hit)           { create(:hit, path: '/common-path', host: runaway_host) }
        let!(:mapping)       { create(:mapping, path: hit.path, site: site) }
        let!(:other_mapping) { create(:mapping, path: hit.path, site: other_site) }

        before do
          # Connect everything with the old hosts
          Transition::Import::HitsMappingsRelations.refresh!

          runaway_host.site = other_site
          runaway_host.save!
        end

        it 'creates relationships which should now exist' do
          expect(hit.reload.mapping).to eql(other_mapping)

          host_path = runaway_host.host_paths.find_by_path(hit.path)
          expect(host_path.mapping).to eql(other_mapping)
          expect(host_path.canonical_path).not_to be_nil
        end

        it 'sets the hit count on the mappings which now have hits' do
          other_mapping.reload
          expect(other_mapping.hit_count).to eq(hit.count)
        end
      end
    end
  end
end
