require "rails_helper"

describe BulkAddBatch do
  describe "callbacks" do
    # In this test, we need to implicitly call #valid? using { be_valid } so
    # that the before_validation callbacks are called so that we can test that
    # they do the right thing.
    context "when there is no scheme" do
      subject(:mappings_batch) { build(:bulk_add_batch, new_url: "www.gov.uk") }

      before { expect(mappings_batch).to be_valid }
      it "should add a scheme" do
        expect(mappings_batch.new_url).to eq("https://www.gov.uk")
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:type).in_array(Mapping::SUPPORTED_TYPES) }

    context "when the mappings batch is invalid" do
      before { expect(mappings_batch).not_to be_valid }

      context "when paths are empty after canonicalisation" do
        subject(:mappings_batch) { build(:bulk_add_batch, paths: ["/"]) }

        it "should declare it invalid" do
          expect(mappings_batch.errors[:canonical_paths]).to eq(["Enter at least one valid path or full URL"])
        end
      end

      context "when it is a redirect" do
        subject(:mappings_batch) { build(:bulk_add_batch, type: "redirect") }

        it "must have a new URL" do
          expect(mappings_batch.errors[:new_url]).to eq(["Enter a valid URL to redirect to"])
        end
      end

      context "when the new URL is too long" do
        subject(:mappings_batch) { build(:bulk_add_batch, type: "redirect", new_url: "http://".ljust(2049, "x")) }

        it "is invalid" do
          expect(mappings_batch.errors[:new_url]).to include("is too long (maximum is 2048 characters)")
        end
      end

      context "when the new URL is invalid" do
        subject(:mappings_batch) { build(:bulk_add_batch, type: "redirect", new_url: "newurl") }

        it "errors and asks for a valid one" do
          expect(mappings_batch.errors[:new_url]).to include("Enter a valid URL to redirect to")
        end
      end

      context "when the new URL is not whitelisted" do
        subject(:mappings_batch) { build(:bulk_add_batch, type: "redirect", new_url: "http://bad.com") }

        it "errors and asks for a whitelisted one" do
          expect(mappings_batch.errors[:new_url]).to include("The URL to redirect to must be on a whitelisted domain. <a href='https://support.publishing.service.gov.uk/general_request/new'>Raise a support request through the GOV.UK Support form</a> for more information.")
        end
      end

      context "when the path list includes a URL for another site" do
        subject(:mappings_batch) { build(:bulk_add_batch, paths: ["http://another.com/foo"]) }

        it "errors and asks for a URL that is part of the current site" do
          expect(mappings_batch.errors[:paths]).to eq(["One or more of the URLs entered are not part of this site"])
        end
      end

      context "when a new URL given to paths is invalid" do
        subject(:mappings_batch) { build(:bulk_add_batch, type: "archive", paths: ["http://newurl/foo[1]"]) }

        it { is_expected.not_to be_valid }
      end
    end

    context "when the path list includes only URLs for this site" do
      let(:host) { create(:host, hostname: "a.com") }
      let(:site) { create(:site_without_host) }

      before do
        site.hosts << host
      end

      subject(:mappings_batch) do
        build(:bulk_add_batch, site: site, paths: ["http://a.com/a", "http://a.com/a"])
      end

      it { is_expected.to be_valid }
    end
  end

  describe "creating entries" do
    let(:site) { create(:site, query_params: "significant") }
    let!(:existing_mapping) { create(:mapping, site: site, path: "/a") }

    subject(:mappings_batch) do
      create(
        :bulk_add_batch,
        site: site,
        paths: ["/a?insignificant", "/a", "/b?significant"],
      )
    end

    it "should create an entry for each canonicalised path" do
      expect(mappings_batch.entries.count).to eq(2)
      entry_paths = mappings_batch.entries.map(&:path)
      expect(entry_paths.sort).to eq(["/a", "/b?significant"].sort)
    end

    it "should relate the entry to the existing mapping" do
      entry = mappings_batch.entries.detect { |mapping_entry| mapping_entry.path == existing_mapping.path }
      expect(entry).not_to be_nil
      expect(entry.mapping).to eq(existing_mapping)
    end

    it "should create entries of the right subclass" do
      entry = mappings_batch.entries.first
      expect(entry).to be_a(BulkAddBatchEntry)
    end
  end

  describe "#process" do
    let(:site) { create(:site) }

    subject(:mappings_batch) do
      create(
        :bulk_add_batch,
        site: site,
        paths: [path, "/b"],
        type: "redirect",
        new_url: new_url,
        tag_list: tag_list,
      )
    end

    let(:path) { "/a" }
    let(:new_url) { "http://a.gov.uk" }
    let(:tag_list) { "a tag" }

    include_examples "creates mappings"
    include_examples "creates redirect mapping"
  end

  describe "recording history", versioning: true do
    let(:site) { create(:site) }
    let(:mappings_batch) do
      create(
        :bulk_add_batch,
        site: site,
        paths: ["/a"],
        type: "redirect",
        new_url: "http://a.gov.uk",
        tag_list: "",
      )
    end

    it "should not record any change to the tag_list" do
      Transition::History.as_a_user(create(:user)) do
        mappings_batch.process
      end

      expect(site.mappings.count).to eq(1)

      mapping = site.mappings.first

      version = mapping.versions.first
      expect(version.changeset).not_to include("tag_list")
    end
  end
end
