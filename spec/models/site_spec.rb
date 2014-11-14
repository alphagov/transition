require 'spec_helper'
require 'postgres/materialized_view'

describe Site do
  describe 'relationships' do
    it { should belong_to(:organisation) }
    it { should have_many(:hosts) }
    it { should have_many(:mappings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:abbr) }
    it { should validate_presence_of(:tna_timestamp) }
    it { should validate_presence_of(:organisation) }
    it { should ensure_inclusion_of(:special_redirect_strategy).in_array(['via_aka', 'supplier']) }
    it { should allow_value("org_site1-Modifier").for(:abbr) }
    it { should_not allow_value("org_www.site").for(:abbr) }

    describe 'homepage' do
      it { should validate_presence_of(:homepage) }

      describe 'the homepage errors' do
        subject(:site) do
          build(:site, homepage: 'www.no-scheme.gov.uk')
        end

        before { site.should_not be_valid }

        it 'should validate the homepage as a full URL' do
          site.errors[:homepage].should == ['is not a URL']
        end
      end
    end

    context 'global redirect' do
      subject(:site) { build(:site, global_type: 'redirect') }

      before { site.should_not be_valid }
      it 'should validate presence of global_new_url' do
        site.errors[:global_new_url].should == ['can\'t be blank']
      end
    end

    context 'global redirect with path appended' do
      subject(:site) { build(:site, global_type: 'redirect', global_redirect_append_path: true, global_new_url: 'http://a.com/?') }

      before { site.should_not be_valid }
      it 'should disallow a global_new_url with a querystring' do
        site.errors[:global_new_url].should == ['cannot contain a query when the path is appended']
      end
    end
  end

  describe 'changing query_params' do
    context 'there are related mappings, host_paths and hits' do
      let!(:host)          { create(:host, site: create(:site, query_params: 'initial')) }
      let!(:site)          { host.site }
      let!(:hit)           { create(:hit, path: '/this/Exists?added_later=2&initial=1', host: host) }
      let!(:mapping)       { create(:mapping, path: hit.path, site: site) }

      let!(:other_hit)     { create(:hit, path: '/something', host: host) }
      let!(:other_mapping) { create(:mapping, path: other_hit.path, site: site) }

      before do
        # Connect everything with the old query_params
        Transition::Import::HitsMappingsRelations.refresh!

        site.update_attribute(:query_params, 'added_later:initial')
      end

      it 'clears relationships which no longer exist' do
        # This host_path and hit shouldn't be related to this mapping any more
        # because they contain what is now an extra significant query param
        # ('added_later=2')

        host_path = HostPath.find_by_path(hit.path)
        host_path.mapping.should eql(nil)

        hit.reload.mapping.should eql(nil)
      end

      it 'should keep relationships which still exist' do
        other_host_path = HostPath.find_by_path(other_hit.path)
        other_host_path.mapping.should eql(other_mapping)

        other_hit.reload.mapping.should eql(other_mapping)
      end
    end
  end

  describe 'scopes' do
    let!(:site_with_mappings)    { create :site }
    let!(:site_without_mappings) { create :site }
    let!(:mappings) { [create(:mapping, site: site_with_mappings),
                       create(:mapping, site: site_with_mappings)] }


    describe '.with_mapping_count' do
      subject(:site_list) { Site.with_mapping_count }

      it 'has counts available on #mapping_count' do
        site = site_list.find { |s| s.id == site_with_mappings.id }
        site.mapping_count.should == 2
      end

      it 'correctly counts 0 for sites without mappings' do
        site = site_list.find { |s| s.id == site_without_mappings.id }
        site.mapping_count.should == 0
      end
    end

    describe '.most_used_tags' do
      before do
        # add some tags to the mappings
        mappings.first.tag_list = 'popular1,popular2,not-popular'
        mappings.last.tag_list  = 'popular1,popular2,still-not-popular'
        mappings.each             { |m| m.save! }

        # add popular tagged mappings with a bigger count to the other site
        # to check we don't include tags from other sites
        3.times do
          create(:mapping, site: site_without_mappings, tag_list: 'popular3')
        end
      end

      subject(:tag_strings) { site_with_mappings.most_used_tags(2) }

      it 'includes the top two tags, but not the less popular tags' do
        tag_strings.should =~ %w(popular1 popular2)
      end
    end
  end

  describe '#transition_status' do
    let!(:site) { create :site_without_host }

    subject(:transition_status) { site.transition_status }

    context 'site has any host redirected by GDS' do
      before do
        create(:host, :with_govuk_cname, site: site)
        create(:host, :with_third_party_cname, site: site)
      end

      it     { should eql(:live) }
    end

    context 'site is under supplier redirect' do
      before { site.special_redirect_strategy = 'supplier' }
      it     { should eql(:indeterminate) }

      context 'but it has a host with a live redirect' do
        before { site.hosts << create(:host, :with_govuk_cname ) }
        it     { should eql(:live) }
      end
    end

    context 'site is under aka redirect' do
      before { site.special_redirect_strategy = 'via_aka' }
      it     { should eql(:indeterminate) }

      context 'but it has a host with a live redirect' do
        before { site.hosts << create(:host, :with_govuk_cname ) }
        it     { should eql(:live) }
      end
    end

    context 'site is not redirected yet, but has aka set up (for testing)' do
      before do
        host = create(:host, :with_third_party_cname, hostname: 'foo.com', site: site)
        create(:host, :with_govuk_cname, hostname: 'aka-foo.com', site: site,
                      canonical_host_id: host.id)
      end

      it { should eql(:pre_transition) }
    end

    context 'in any other case' do
      it { should eql(:pre_transition) }
    end
  end

  # given that hosts are site aliases
  describe '#default_host' do
    let(:site) { create :site_without_host }

    before do
      create(:host, :with_its_aka_host, hostname: 'www.f.com', site: site)
    end

    subject(:default_host) do
      site.default_host
    end

    its(:hostname) { should eql('www.f.com') }
  end

  describe '#canonical_path' do
    let(:site) do
      create(:site, query_params: "foo:bar")
    end
    subject(:canonicalized_path) { site.canonical_path(@raw_path) }

    it "should be a canonicalized path" do
      @raw_path = '/ABOUT/FUN///#noreally'
      subject.should eql('/about/fun')
    end

    it "should retain the site's significant query params" do
      @raw_path = '/ABOUT?foo=BAZ&bar=beer'
      subject.should eql('/about?bar=beer&foo=baz')
    end

    it "should not retain other query params" do
      @raw_path = '/ABOUT?foo=BAZ&rain=shine'
      subject.should eql('/about?foo=baz')
    end

    it "should handle an empty path gracefully" do
      @raw_path = '/'
      subject.should eql('')
    end

    it "inserts a missing first slash" do
      @raw_path = 'foo'
      subject.should eql('/foo')
    end

    it "inserts a missing first slash, unless the first part appears to be a domain" do
      @raw_path = 'www.a.gov.uk/foo'
      subject.should eql('/foo')
    end

    it "handles absolute URLs" do
      @raw_path = 'http://www.a.gov.uk/foo'
      subject.should eql('/foo')
    end
  end

  describe '#hit_total_count' do
    let(:site) { create :site }

    subject    { site.hit_total_count }

    context 'the site has no hits at all' do
      it { should be_zero }
    end

    context 'the site has hits' do
      before do
        site.default_host.hits.concat [
          create(:hit, path: '/1', hit_on: Date.today, count: 10),
          create(:hit, path: '/2', hit_on: Date.yesterday, count: 20)
        ]

        Transition::Import::DailyHitTotals.from_hits!
      end

      it { should == 30 }
    end
  end

  describe 'precomputed views' do
    subject(:site) { build :site, abbr: 'hmrc', precompute_all_hits_view: false }

    it 'quotes a conventional view name' do
      site.precomputed_view_name.should eql('"hmrc_all_hits"')
    end

    describe '#able_to_use_view?' do
      context 'the view is not there' do
        before { Postgres::MaterializedView.stub(:exist?).and_return(false) }

        it { should_not be_able_to_use_view }
      end
      context 'the view is there, but precompute_hits_view is false' do
        before { Postgres::MaterializedView.stub(:exist?).and_return(true) }

        it { should_not be_able_to_use_view }
      end
      context 'the view is there and precompute_hits_view is true' do
        before do
          site.precompute_all_hits_view = true
          Postgres::MaterializedView.should_receive(:exist?).and_return(true)
        end

        it { should be_able_to_use_view }
      end
    end
  end
end
