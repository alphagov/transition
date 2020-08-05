require "rails_helper"
require "transition/import/hits_mappings_relations"
require "transition/history"

describe Mapping do
  specify { expect(PaperTrail).not_to be_enabled } # testing our tests a little here, but if this fails, tests will be slow

  describe "relationships" do
    it { is_expected.to belong_to(:site) }
  end

  describe "#redirect?" do
    describe "#redirect?" do
      subject { super().redirect? }
      it { is_expected.to be_falsey }
    end
    it "is true when its type is redirect" do
      subject.type = "redirect"
      expect(subject.redirect?).to be_truthy
    end
  end

  describe "#archive?" do
    describe "#archive?" do
      subject { super().archive? }
      it { is_expected.to be_falsey }
    end
    it "is true when its type is archive" do
      subject.type = "archive"
      expect(subject.archive?).to be_truthy
    end
  end

  describe "#unresolved?" do
    describe "#unresolved?" do
      subject { super().unresolved? }
      it { is_expected.to be_falsey }
    end
    it "is true when its type is unresolved" do
      subject.type = "unresolved"
      expect(subject.unresolved?).to be_truthy
    end
  end

  describe "url generation (based on mapping path and site host)" do
    subject(:mapping) { create :mapping, site: create(:site, abbr: "cic_regulator"), path: "/some-path" }

    describe "#old_url" do
      subject { super().old_url }
      it { is_expected.to eq("http://cic_regulator.gov.uk/some-path") }
    end

    describe "#national_archive_url" do
      subject { super().national_archive_url }
      it { is_expected.to eq("http://webarchive.nationalarchives.gov.uk/20120816224015/http://cic_regulator.gov.uk/some-path") }
    end

    describe "#national_archive_index_url" do
      subject { super().national_archive_index_url }
      it { is_expected.to eq("http://webarchive.nationalarchives.gov.uk/*/http://cic_regulator.gov.uk/some-path") }
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:site) }
    it { is_expected.to validate_presence_of(:path) }

    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_inclusion_of(:type).in_array(Mapping::SUPPORTED_TYPES) }

    describe "home pages (which are handled by Site)" do
      subject(:homepage_mapping) { build(:mapping, path: "/") }

      before { expect(homepage_mapping).not_to be_valid }
      it "disallows homepages" do
        expect(homepage_mapping.errors[:path]).to eq(
          ["It’s not currently possible to edit the mapping for a site’s homepage."],
        )
      end
    end

    it { is_expected.to validate_length_of(:path).is_at_most(2048) }
    it "ensures paths are unique to a site" do
      site = create(:site)
      create(:archived, path: "/foo", site: site)
      expect { build(:archived, path: "/foo", site: site).save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "constrains the length of all URL fields" do
      too_long_url = "http://".ljust(2049, "x")

      %i[new_url suggested_url archive_url].each do |url_attr|
        mapping = build(:mapping, url_attr => too_long_url)
        expect(mapping).not_to be_valid
        expect(mapping.errors[url_attr]).to include("is too long (maximum is 2048 characters)")
      end
    end

    describe "URL validations" do
      before { mapping.valid? }

      context "oh golly, everything is wrong" do
        subject(:mapping) do
          build(:redirect, new_url: "https://", suggested_url: "http://", archive_url: "")
        end

        describe "the errors" do
          subject { mapping.errors }

          describe "[:new_url]" do
            subject { super()[:new_url] }
            it { is_expected.to include("is not a URL") }
          end

          describe "[:suggested_url]" do
            subject { super()[:suggested_url] }
            it { is_expected.to eq(["is not a URL"]) }
          end

          describe "[:archive_url]" do
            subject { super()[:archive_url] }
            it { is_expected.to be_empty }
          end

          context "failure to supply a new URL for a redirect" do
            before do
              mapping.new_url = ""
              expect(mapping).not_to be_valid
            end

            describe "[:new_url]" do
              subject { super()[:new_url] }
              it { is_expected.to eq(["is required"]) }
            end
          end
        end
      end

      context 'URLs with an invalid host (without a ".")' do
        subject(:mapping) do
          build(:redirect, new_url: "newurl", suggested_url: "suggestedurl")
        end

        describe "the errors" do
          subject { mapping.errors }

          describe "[:new_url]" do
            subject { super()[:new_url] }
            it { is_expected.to include("is not a URL") }
          end

          describe "[:suggested_url]" do
            subject { super()[:suggested_url] }
            it { is_expected.to eq(["is not a URL"]) }
          end
        end
      end

      context "Archive URL is not webarchive.nationalarchives.gov.uk" do
        subject(:mapping) { build(:archived, archive_url: "http://malicious.com/foo") }

        it "fails" do
          expect(mapping.errors[:archive_url]).to eq(["must be on the National Archives domain, webarchive.nationalarchives.gov.uk"])
        end
      end

      describe "New URL whitelist checks" do
        context "not in the whitelist" do
          subject(:mapping) { build(:redirect, new_url: "http://m.com/foo") }

          it "fails" do
            expect(mapping.errors[:new_url]).to eq(["must be on a whitelisted domain. <a href='https://support.publishing.service.gov.uk/general_request/new'>Raise a support request through the GOV.UK Support form</a> for more information."])
          end
        end

        context "is in the whitelist" do
          before { create(:whitelisted_host, hostname: "whitelisted.com") }
          subject(:mapping) { build(:redirect, new_url: "http://whitelisted.com/a") }

          it { is_expected.to be_valid }
        end

        context "is on *.gov.uk" do
          subject(:mapping) { build(:redirect, new_url: "http://m.gov.uk/foo") }

          it { is_expected.to be_valid }
        end

        context "is on *.mod.uk" do
          subject(:mapping) { build(:redirect, new_url: "http://m.mod.uk/foo") }

          it { is_expected.to be_valid }
        end

        context "is on *.nhs.uk" do
          subject(:mapping) { build(:redirect, new_url: "http://m.nhs.uk/foo") }

          it { is_expected.to be_valid }
        end

        context "mapping is not a redirect" do
          subject(:mapping) { build(:archived, new_url: "http://evil.com") }

          it { is_expected.to be_valid }
          it "still saves the value that would be invalid if it was a redirect" do
            mapping.save!
            expect(mapping.reload.new_url).to eq("http://evil.com")
          end
        end
      end

      context "path is blank" do
        subject(:mapping) { build(:archived, path: "") }

        it "fails" do
          expect(mapping.errors[:path]).to eq(["can't be blank"])
        end
      end

      context "path does not start with a /" do
        subject(:mapping) { build(:archived, path: "not_a_path") }

        it "fails" do
          expect(mapping.errors[:path]).to eq(['must start with a forward slash "/"'])
        end
      end
    end

    describe "tagging behaviour for quoting and special characters" do
      let(:mapping)      { create :mapping }

      subject(:tag_list) { mapping.tag_list }

      before { mapping.tag_list = test_input }

      context "there are double-quoted tags" do
        let(:test_input) { %("Fee fi", "FO", fum, thing:1234) }
        it { is_expected.to eql(["fee fi", "fo", "fum", "thing:1234"]) }
      end
      context "there are double-quotes in tags" do
        let(:test_input) { %("Fee \"fi fo fum\"", thing:1234) }
        it { is_expected.to eql(['fee "fi fo fum"', "thing:1234"]) }
      end
      context "there are single-quoted tags" do
        let(:test_input) { %('Fee fi', 'FO', fum, thing:1234) }
        it { is_expected.to eql(["fee fi", "fo", "fum", "thing:1234"]) }
      end
      context "there are single-quotes in tags" do
        let(:test_input) { %("Fee 'fi fo fum'", thing:1234) }
        it { is_expected.to eql(["fee 'fi fo fum'", "thing:1234"]) }
      end
      context "there are special characters" do
        let(:test_input) { %('<Fee fi>', '\\FO/', ¿fum?) }
        it { is_expected.to eql(["<fee fi>", '\\fo/', "¿fum?"]) }
      end
      context "there are blanks" do
        let(:test_input) { %(,     ,    hello, hi    , ho) }
        it { is_expected.to eql(%w[hello hi ho]) }
      end
      context "there are only blanks" do
        let(:test_input) { %(,     ,       , ,   ) }
        it { is_expected.to eql([]) }
      end
    end
  end

  describe "scopes" do
    describe ".filtered_by_path" do
      before do
        site = create :site
        ["/a", "/about", "/about/branding", "/other"].each do |path|
          create :mapping, path: path, site: site
        end
      end

      context "a filter is supplied" do
        subject { Mapping.filtered_by_path("about").map(&:path) }

        it { is_expected.to include("/about") }
        it { is_expected.to include("/about/branding") }
        it { is_expected.not_to include("/a") }
        it { is_expected.not_to include("/other") }
      end

      context "no filter is supplied" do
        subject { Mapping.filtered_by_path(nil) }

        it "has 4 mappings" do
          expect(subject.size).to eq(4)
        end
      end
    end

    describe ".filtered_by_new_url" do
      before do
        site = create :site
        ["/a", "/about", "/about/branding", "/other"].each do |new_path|
          create :mapping, new_url: "http://f.gov.uk#{new_path}", site: site
        end
      end

      context "a filter is supplied" do
        subject { Mapping.filtered_by_new_url("about").map(&:new_url) }

        it { is_expected.to include("http://f.gov.uk/about") }
        it { is_expected.to include("http://f.gov.uk/about/branding") }
        it { is_expected.not_to include("http://f.gov.uk/a") }
        it { is_expected.not_to include("http://f.gov.uk/other") }
      end

      context "no filter is supplied" do
        subject { Mapping.filtered_by_path(nil) }

        it "has 4 mappings" do
          expect(subject.size).to eq(4)
        end
      end
    end
  end

  describe "path canonicalization and relation to hits" do
    let(:uncanonicalized_path) { "/A/b/c?significant=1&really-significant=2&insignificant=2" }
    let(:canonicalized_path)   { "/a/b/c?really-significant=2&significant=1" }
    let(:site)                 { create(:site, query_params: "significant:really-significant") }

    subject(:mapping) do
      create(:archived, path: uncanonicalized_path, site: site)
    end

    describe "#path" do
      subject { super().path }
      it { is_expected.to eql(canonicalized_path) }
    end

    describe "the linkage to hits" do
      let!(:hit_on_uncanonicalized) { create :hit, path: uncanonicalized_path, host: site.default_host }
      let!(:host_path_on_uncanonicalized) { create :host_path, path: uncanonicalized_path, host: site.default_host }

      let!(:hit_on_canonicalized) { create :hit, path: canonicalized_path, host: site.default_host }
      let!(:host_path_on_canonicalized) { create :host_path, path: canonicalized_path, host: site.default_host }

      let!(:unrelated_hit) { create :hit, path: "/just-zis-guy", host: site.default_host }
      let!(:unrelated_host_path) { create :host_path, path: "/just-zis-guy", host: site.default_host }

      context "when creating a new mapping" do
        before do
          Transition::Import::HitsMappingsRelations.refresh!
          mapping.save!
        end

        it "links the uncanonicalized hit to the mapping" do
          expect(hit_on_uncanonicalized.reload.mapping).to eq(mapping)
        end

        it "links the canonicalized hit to the mapping" do
          expect(hit_on_canonicalized.reload.mapping).to eq(mapping)
        end

        it "links the uncanonicalized host_path to the mapping" do
          expect(host_path_on_uncanonicalized.reload.mapping).to eq(mapping)
        end

        it "link the canonicalized host_path to the mapping" do
          expect(host_path_on_canonicalized.reload.mapping).to eq(mapping)
        end

        it "updates the hit_count" do
          expect(mapping.hit_count).to eq(40)
        end

        it "should leave an unrelated hit alone" do
          expect(unrelated_hit.reload.mapping).to be_nil
        end

        it "should leave an unrelated host_path alone" do
          expect(unrelated_host_path.reload.mapping).to be_nil
        end
      end
    end
  end

  describe "nillifying blanks before validation" do
    subject(:mapping) do
      create :archived, archive_url: ""
    end

    describe "#archive_url" do
      subject { super().archive_url }
      it { is_expected.to be_nil }
    end
  end

  it "should rewrite the URLs to ensure they have a scheme before validation" do
    mapping = build(
      :archived,
      suggested_url: "www.example.com",
      archive_url: "webarchive.nationalarchives.gov.uk",
      new_url: "www.gov.uk",
    )

    mapping.valid? # trigger before_validation hooks

    expect(mapping.suggested_url).to eql("http://www.example.com")
    expect(mapping.archive_url).to eql("http://webarchive.nationalarchives.gov.uk")
    expect(mapping.new_url).to eql("https://www.gov.uk")
  end

  it "converts URLs supplied for path into a path, including query" do
    site = create(:site, query_params: "q")
    mapping = create(:mapping, path: "http://www.example.com/foobar?q=1", site: site)
    expect(mapping.path).to eq("/foobar?q=1")
  end

  it "has a paper trail" do
    is_expected.to be_versioned
  end

  describe "The paper trail", versioning: true do
    let(:alice) { create :user, name: "Alice" }
    let(:bob)   { create :user, name: "Bob" }
    let(:lisa)  { create :user, name: "Lisa" }

    context "with the correct configuration" do
      subject(:mapping) { create :mapping, as_user: alice }

      it "has 1 version" do
        expect(subject.versions.size).to eq(1)
      end

      describe "the last version" do
        subject { mapping.versions.last }

        describe "#whodunnit" do
          subject { super().whodunnit }
          it { is_expected.to eql alice.name }
        end

        describe "#user_id" do
          subject { super().user_id }
          it { is_expected.to eql alice.id }
        end

        describe "#event" do
          subject { super().event }
          it { is_expected.to eql "create" }
        end
      end

      describe "an update from Bob" do
        before do
          Transition::History.as_a_user(bob) do
            mapping.update(new_url: "http://updated.gov.uk")
          end
        end

        it "has 2 versions" do
          expect(subject.versions.size).to eq(2)
        end

        describe "the last version" do
          subject { mapping.versions.last }

          describe "#whodunnit" do
            subject { super().whodunnit }
            it { is_expected.to eql bob.name }
          end

          describe "#user_id" do
            subject { super().user_id }
            it { is_expected.to eql bob.id }
          end

          describe "#event" do
            subject { super().event }
            it { is_expected.to eql "update" }
          end
        end
      end

      context "versioning for tag_list" do
        subject(:mapping) { create :mapping, as_user: lisa }

        describe "an update from Lisa" do
          before do
            Transition::History.as_a_user(lisa) do
              mapping.tag_list = %w[cool_tag]
              mapping.save!
            end
          end

          it "has 2 versions" do
            expect(subject.versions.size).to eq(2)
          end

          describe "the last version" do
            subject { mapping.versions.last }

            it "records an update event" do
              expect(subject.event).to eq("update")
            end

            it "records the change to tag_list" do
              expect(subject.changeset).to include("tag_list")
            end
          end
        end
      end
    end

    context "without the correct configuration" do
      it "should fail with an exception" do
        expect { create :mapping, as_user: nil }.to raise_error(Transition::History::PaperTrailUserNotSetError)
      end
    end
  end

  describe "edited_by_human" do
    context "imported from redirector" do
      subject(:mapping) { create(:mapping, from_redirector: true) }

      describe "#edited_by_human?" do
        subject { super().edited_by_human? }
        it { is_expected.to be_truthy }
      end
    end

    context "has been edited by a human", versioning: true do
      let(:human) { create :user }

      subject(:mapping) { create(:mapping, as_user: human) }

      describe "#edited_by_human?" do
        subject { super().edited_by_human? }
        it { is_expected.to be_truthy }
      end
    end

    context "has been edited by a robot", versioning: true do
      let(:robot) { create :user, is_robot: true }

      subject(:mapping) { create(:mapping, as_user: robot) }

      describe "#edited_by_human?" do
        subject { super().edited_by_human? }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe "last_editor" do
    context "no versions exist" do
      subject(:mapping) { create(:mapping, from_redirector: true) }

      describe "#last_editor" do
        subject { super().last_editor }
        it { is_expected.to be_nil }
      end
    end

    context "versions exist", versioning: true do
      let(:user) { create :user }
      subject(:mapping) { create(:mapping, as_user: user) }

      context "only one version exists" do
        describe "#last_editor" do
          subject { super().last_editor }
          it { is_expected.to eql(user) }
        end
      end

      context "several versions exist" do
        let(:other_user) { create :user }
        before do
          Transition::History.as_a_user(other_user) do
            mapping.update!(type: "redirect", new_url: "http://updated.gov.uk")
            mapping.update!(type: "redirect", new_url: "http://new.gov.uk")
          end
        end

        it "has 3 versions" do
          expect(subject.versions.size).to eq(3)
        end

        describe "#last_editor" do
          subject { super().last_editor }
          it { is_expected.to eql(other_user) }
        end
      end
    end
  end
end
