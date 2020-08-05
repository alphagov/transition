require "rails_helper"
require "postgres/materialized_view"

describe Site do
  describe "relationships" do
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to have_many(:hosts) }
    it { is_expected.to have_many(:mappings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:abbr) }
    it { is_expected.to validate_presence_of(:tna_timestamp) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_inclusion_of(:special_redirect_strategy).in_array(%w[via_aka supplier]) }
    it { is_expected.to allow_value("org_site1-Modifier").for(:abbr) }
    it { is_expected.not_to allow_value("org_www.site").for(:abbr) }

    describe "homepage" do
      it { is_expected.to validate_presence_of(:homepage) }

      describe "the homepage errors" do
        subject(:site) do
          build(:site, homepage: "www.no-scheme.gov.uk")
        end

        before { expect(site).not_to be_valid }

        it "should validate the homepage as a full URL" do
          expect(site.errors[:homepage]).to eq(["is not a URL"])
        end
      end
    end

    context "global redirect" do
      subject(:site) { build(:site, global_type: "redirect") }

      before { expect(site).not_to be_valid }
      it "should validate presence of global_new_url" do
        expect(site.errors[:global_new_url]).to eq(["can't be blank"])
      end
    end

    context "global redirect with path appended" do
      subject(:site) { build(:site, global_type: "redirect", global_redirect_append_path: true, global_new_url: "http://a.com/?") }

      before { expect(site).not_to be_valid }
      it "should disallow a global_new_url with a querystring" do
        expect(site.errors[:global_new_url]).to eq(["cannot contain a query when the path is appended"])
      end
    end
  end

  describe "changing query_params" do
    context "there are related mappings, host_paths and hits" do
      let!(:host)          { create(:host, site: create(:site, query_params: "initial")) }
      let!(:site)          { host.site }
      let!(:hit)           { create(:hit, path: "/this/Exists?added_later=2&initial=1", host: host) }
      let!(:mapping)       { create(:mapping, path: hit.path, site: site) }

      let!(:other_hit)     { create(:hit, path: "/something", host: host) }
      let!(:other_mapping) { create(:mapping, path: other_hit.path, site: site) }

      before do
        # Connect everything with the old query_params
        Transition::Import::HitsMappingsRelations.refresh!

        site.update!(query_params: "added_later:initial")
      end

      it "clears relationships which no longer exist" do
        # This host_path and hit shouldn't be related to this mapping any more
        # because they contain what is now an extra significant query param
        # ('added_later=2')

        host_path = HostPath.find_by(path: hit.path)
        expect(host_path.mapping).to eql(nil)

        expect(hit.reload.mapping).to eql(nil)
      end

      it "should keep relationships which still exist" do
        other_host_path = HostPath.find_by(path: other_hit.path)
        expect(other_host_path.mapping).to eql(other_mapping)

        expect(other_hit.reload.mapping).to eql(other_mapping)
      end
    end
  end

  describe "scopes" do
    let!(:site_with_mappings)    { create :site }
    let!(:site_without_mappings) { create :site }
    let!(:mappings) do
      [
        create(:mapping, site: site_with_mappings),
        create(:mapping, site: site_with_mappings),
      ]
    end

    describe ".with_mapping_count" do
      subject(:site_list) { Site.with_mapping_count }

      it "has counts available on #mapping_count" do
        site = site_list.find { |s| s.id == site_with_mappings.id }
        expect(site.mapping_count).to eq(2)
      end

      it "correctly counts 0 for sites without mappings" do
        site = site_list.find { |s| s.id == site_without_mappings.id }
        expect(site.mapping_count).to eq(0)
      end
    end

    describe ".most_used_tags" do
      before do
        # add some tags to the mappings
        mappings.first.tag_list = "popular1,popular2,not-popular"
        mappings.last.tag_list  = "popular1,popular2,still-not-popular"
        mappings.each(&:save!)

        # add popular tagged mappings with a bigger count to the other site
        # to check we don't include tags from other sites
        3.times do
          create(:mapping, site: site_without_mappings, tag_list: "popular3")
        end
      end

      subject(:tag_strings) { site_with_mappings.most_used_tags(2) }

      it "includes the top two tags, but not the less popular tags" do
        expect(tag_strings).to match_array(%w[popular1 popular2])
      end
    end
  end

  describe "#transition_status" do
    let!(:site) { create :site_without_host }

    subject(:transition_status) { site.transition_status }

    context "site has any host redirected by GDS" do
      before do
        create(:host, :with_govuk_cname, site: site)
        create(:host, :with_third_party_cname, site: site)
      end

      it { is_expected.to eql(:live) }
    end

    context "site is under supplier redirect" do
      before { site.special_redirect_strategy = "supplier" }
      it { is_expected.to eql(:indeterminate) }

      context "but it has a host with a live redirect" do
        before { site.hosts << create(:host, :with_govuk_cname) }
        it { is_expected.to eql(:live) }
      end
    end

    context "site is under aka redirect" do
      before { site.special_redirect_strategy = "via_aka" }
      it { is_expected.to eql(:indeterminate) }

      context "but it has a host with a live redirect" do
        before { site.hosts << create(:host, :with_govuk_cname) }
        it { is_expected.to eql(:live) }
      end
    end

    context "site is not redirected yet, but has aka set up (for testing)" do
      before do
        host = create(:host, :with_third_party_cname, hostname: "foo.com", site: site)
        create(
          :host,
          :with_govuk_cname,
          hostname: "aka-foo.com",
          site: site,
          canonical_host_id: host.id,
        )
      end

      it { is_expected.to eql(:pre_transition) }
    end

    context "in any other case" do
      it { is_expected.to eql(:pre_transition) }
    end
  end

  # given that hosts are site aliases
  describe "#default_host" do
    let(:site) { create :site_without_host }

    before do
      create(:host, :with_its_aka_host, hostname: "www.f.com", site: site)
    end

    subject(:default_host) do
      site.default_host
    end

    describe "#hostname" do
      subject { super().hostname }
      it { is_expected.to eql("www.f.com") }
    end
  end

  describe "#canonical_path" do
    let(:site) do
      create(:site, query_params: "foo:bar")
    end
    subject(:canonicalized_path) { site.canonical_path(@raw_path) }

    it "should be a canonicalized path" do
      @raw_path = "/ABOUT/FUN///#noreally"
      expect(subject).to eql("/about/fun")
    end

    it "should retain the site's significant query params" do
      @raw_path = "/ABOUT?foo=BAZ&bar=beer"
      expect(subject).to eql("/about?bar=beer&foo=baz")
    end

    it "should not retain other query params" do
      @raw_path = "/ABOUT?foo=BAZ&rain=shine"
      expect(subject).to eql("/about?foo=baz")
    end

    it "should handle an empty path gracefully" do
      @raw_path = "/"
      expect(subject).to eql("")
    end

    it "inserts a missing first slash" do
      @raw_path = "foo"
      expect(subject).to eql("/foo")
    end

    it "inserts a missing first slash, unless the first part appears to be a domain" do
      @raw_path = "www.a.gov.uk/foo"
      expect(subject).to eql("/foo")
    end

    it "handles absolute URLs" do
      @raw_path = "http://www.a.gov.uk/foo"
      expect(subject).to eql("/foo")
    end
  end

  describe "#hit_total_count" do
    let(:site) { create :site }

    subject { site.hit_total_count }

    context "the site has no hits at all" do
      it { is_expected.to be_zero }
    end

    context "the site has hits" do
      before do
        site.default_host.hits.concat [
          create(:hit, path: "/1", hit_on: Time.zone.today, count: 10),
          create(:hit, path: "/2", hit_on: Time.zone.yesterday, count: 20),
        ]

        Transition::Import::DailyHitTotals.from_hits!
      end

      it { is_expected.to eq(30) }
    end
  end

  describe "precomputed views" do
    let(:precompute) { false }

    subject(:site) { build :site, abbr: "hmrc", precompute_all_hits_view: precompute }

    it "calculates a conventional view name" do
      expect(site.precomputed_view_name).to eql("hmrc_all_hits")
    end

    describe "#able_to_use_view?" do
      context "the view is not there" do
        before { allow(Postgres::MaterializedView).to receive(:exists?).and_return(false) }

        it { is_expected.not_to be_able_to_use_view }
      end
      context "the view is there, but precompute_hits_view is false" do
        before { allow(Postgres::MaterializedView).to receive(:exists?).and_return(true) }

        it { is_expected.not_to be_able_to_use_view }
      end
      context "the view is there and precompute_hits_view is true" do
        let(:precompute) { true }
        before do
          expect(Postgres::MaterializedView).to receive(:exists?).and_return(true)
        end

        it { is_expected.to be_able_to_use_view }
      end
    end

    describe "the automatic removal of un-needed views" do
      let(:precompute) { true }

      context "precompute_all_hits_view is set to false from true" do
        before do
          site.save!
          expect(Postgres::MaterializedView).to receive(:drop).with(site.precomputed_view_name)
        end

        it "drops the view" do
          # testing the should_receive expectation in the before block
          site.update(precompute_all_hits_view: false)
        end
      end
    end
  end
end
