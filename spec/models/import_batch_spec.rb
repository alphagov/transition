require "rails_helper"

describe ImportBatch do
  describe "validations" do
    it { is_expected.to validate_presence_of(:raw_csv).with_message("Enter at least one valid line") }

    describe "old URLs" do
      let(:host) { create(:host, hostname: "a.com") }
      let(:site) { create(:site_without_host) }

      before do
        site.hosts << host
      end

      describe "old_urls includes URLs for this site" do
        subject(:mappings_batch) do
          build(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              http://a.com/old,
          CSV
          )
        end

        it { is_expected.to be_valid }
      end

      describe "old_urls includes URLs which are not for this site" do
        subject(:mappings_batch) do
          build(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              http://other.com/old,
          CSV
          )
        end

        it { is_expected.not_to be_valid }
        it "should declare them invalid" do
          mappings_batch.valid?
          expect(mappings_batch.errors[:old_urls]).to eq(["One or more of the URLs entered are not part of this site"])
        end
      end

      describe "old URLs would be empty after canonicalisation" do
        subject(:mappings_batch) do
          build(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              old,
          CSV
          )
        end

        before { expect(mappings_batch).not_to be_valid }
        it "should declare it invalid" do
          expect(mappings_batch.errors[:canonical_paths]).to eq(["Enter at least one valid path or full URL"])
        end
      end
    end

    describe "new URLs" do
      describe "validating all new URLs for length" do
        let(:too_long_url) { "http://a.gov.uk".ljust(65_536, "x") }
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,#{too_long_url}
          CSV
          )
        end

        before { expect(mappings_batch).not_to be_valid }
        it "should declare it invalid" do
          expect(mappings_batch.errors[:new_urls]).to include("A new URL is too long")
        end
      end

      describe "validating that all new URLs are valid URLs" do
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,www.gov.uk
          CSV
          )
        end

        before { expect(mappings_batch).not_to be_valid }
        it "should declare it invalid" do
          expect(mappings_batch.errors[:new_urls]).to include("A new URL is invalid")
        end
      end

      describe "validating that all new URLs are on the whitelist" do
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,http://evil.com
          CSV
          )
        end

        before { expect(mappings_batch).not_to be_valid }
        it "should declare it invalid" do
          expect(mappings_batch.errors[:new_urls]).to include("The URL to redirect to must be on a whitelisted domain. <a href='https://support.publishing.service.gov.uk/general_request/new'>Raise a support request through the GOV.UK Support form</a> for more information.")
        end
      end

      context "when an invalid new URL appears multiple times in the raw CSV" do
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              /old-1,http://evil.com
              /old-2,http://evil.com
              /old-3,http://evil.com
              /old-4,http://evil.com
              /old-5,http://evil.com
              /old-6,http://also-bad.com
          CSV
          )
        end

        before { expect(mappings_batch).not_to be_valid }
        it "should include the error message once per unique new URL" do
          expect(mappings_batch.errors.details[:new_urls].size).to eql(2)
        end
      end
    end

    describe "archive URLs" do
      describe "validating all archive URLs for length" do
        let(:too_long_url) { "http://webarchive.nationalarchives.gov.uk/*/http://a.com".ljust(65_536, "x") }
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,#{too_long_url}
          CSV
          )
        end

        before { expect(mappings_batch).not_to be_valid }
        it "should declare it invalid" do
          expect(mappings_batch.errors[:archive_urls]).to include("A new URL is too long")
        end
      end
    end
  end

  describe "creating entries" do
    let(:site) { create(:site, query_params: "significant") }
    let!(:mappings_batch) do
      create(
        :import_batch,
        site: site,
        raw_csv: raw_csv,
      )
    end
    context "rosy case" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          /old,https://www.gov.uk/new
        CSV
      end

      it "should create an entry for each data row" do
        expect(mappings_batch.entries.count).to eq(1)
      end

      describe "the first entry" do
        subject(:entry) { mappings_batch.entries.first }

        describe "#path" do
          subject { super().path }
          it { is_expected.to eq("/old") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/new") }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end
        it "should create an entry of the right subclass" do
          expect(entry).to be_a(ImportBatchEntry)
        end
      end
    end

    context "with headers" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          old url,new url
          /old,https://www.gov.uk/new
          old_url, new_url
        CSV
      end

      it "should ignore headers" do
        expect(mappings_batch.entries.count).to eq(1)
        entry = mappings_batch.entries.first
        expect(entry.path).to eq("/old")
      end
    end

    context "with blank lines" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          /old,https://www.gov.uk/new

        CSV
      end

      it "should ignore blank lines" do
        expect(mappings_batch.entries.count).to eq(1)
        entry = mappings_batch.entries.first
        expect(entry.path).to eq("/old")
      end
    end

    context "with lines containing only a separator" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          /old,https://www.gov.uk/new
          ,
        CSV
      end

      it "should ignore those lines" do
        expect(mappings_batch.entries.count).to eq(1)
        entry = mappings_batch.entries.first
        expect(entry.path).to eq("/old")
      end
    end

    context "archives" do
      context "without a custom archive URL" do
        let(:raw_csv) do
          <<-CSV.strip_heredoc
            /old,TNA
          CSV
        end
        it "should create an entry for each data row" do
          expect(mappings_batch.entries.count).to eq(1)
        end

        describe "the first entry" do
          subject(:entry) { mappings_batch.entries.first }

          describe "#path" do
            subject { super().path }
            it { is_expected.to eq("/old") }
          end

          describe "#new_url" do
            subject { super().new_url }
            it { is_expected.to be_nil }
          end

          describe "#archive_url" do
            subject { super().archive_url }
            it { is_expected.to be_nil }
          end

          describe "#type" do
            subject { super().type }
            it { is_expected.to eq("archive") }
          end
        end
      end

      context "with custom archive URL" do
        let(:archive_url) { "http://webarchive.nationalarchives.gov.uk/20160701131101/http://blogs.bis.gov.uk/exportcontrol/open-licensing/httpblogs-bis-gov-ukexportcontroluncategorizednotice-to-exporters-201415-uk-suspends-all-licences-and-licence-applications-for-export-to-russian-military-that-could-be-used-against-ukraine/" }
        let(:raw_csv) do
          <<-CSV.strip_heredoc
            /old,#{archive_url}
          CSV
        end
        it "should create an entry for each data row" do
          expect(mappings_batch.entries.count).to eq(1)
        end

        describe "the first entry" do
          subject(:entry) { mappings_batch.entries.first }

          describe "#path" do
            subject { super().path }
            it { is_expected.to eq("/old") }
          end

          describe "#new_url" do
            subject { super().new_url }
            it { is_expected.to be_nil }
          end

          describe "#archive_url" do
            subject { super().archive_url }
            it { is_expected.to eq(archive_url) }
          end

          describe "#type" do
            subject { super().type }
            it { is_expected.to eq("archive") }
          end
        end
      end
    end

    context "unresolved" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          /old
        CSV
      end
      it "should create an entry for each data row" do
        expect(mappings_batch.entries.count).to eq(1)
      end

      describe "the first entry" do
        subject(:entry) { mappings_batch.entries.first }

        describe "#path" do
          subject { super().path }
          it { is_expected.to eq("/old") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to be_nil }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("unresolved") }
        end
      end
    end

    context "the old URL is an absolute URL, not a path" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          http://#{site.default_host.hostname}/old
        CSV
      end

      it "sets the path to be only the path" do
        expect(mappings_batch.entries.first.path).to eql("/old")
      end
    end

    context "the old URL canonicalizes to a homepage path" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          /?foo
          /a
        CSV
      end

      it "does not create an entry for the homepage row" do
        expect(mappings_batch.entries.pluck(:path)).to eql(["/a"])
      end
    end

    context "deduplicating rows" do
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          /old,
          /old?insignificant,TNA
          /OLD,http://a.gov.uk/new
          /old,http://a.gov.uk/ignore-later-redirects
        CSV
      end

      it "should canonicalize and deduplicate before creating entries" do
        expect(mappings_batch.entries.count).to eq(1)

        entry = mappings_batch.entries.first
        expect(entry.path).to eq("/old")
        expect(entry.new_url).to eq("http://a.gov.uk/new")
        expect(entry.type).to eq("redirect")
      end
    end

    context "existing mappings" do
      let(:existing_mapping) { create(:mapping, site: site, path: "/old") }
      let(:raw_csv) do
        <<-CSV.strip_heredoc
          #{existing_mapping.path}
        CSV
      end

      it "should relate the entry to the existing mapping" do
        entry = mappings_batch.entries.detect { |mapping_entry| mapping_entry.path == existing_mapping.path }
        expect(entry).not_to be_nil
        expect(entry.mapping).to eq(existing_mapping)
      end
    end
  end

  describe "#process" do
    let(:site) { create(:site) }

    subject(:mappings_batch) do
      create(
        :import_batch,
        site: site,
        tag_list: tag_list,
        raw_csv: <<-CSV.strip_heredoc,
                   #{path_to_be_redirected},#{new_url}
                   #{path_to_be_archived},#{archive_url}
        CSV
      )
    end

    let(:path_to_be_redirected) { "/a" }
    let(:new_url) { "http://a.gov.uk" }

    let(:path_to_be_archived) { "/b" }
    let(:archive_url) { "http://webarchive.nationalarchives.gov.uk/*/http://a.com/foo" }

    let(:tag_list) { "a tag" }

    include_examples "creates mappings"

    context "with a redirect mapping" do
      let(:path) { path_to_be_redirected }

      include_examples "creates redirect mapping"
    end

    context "with a custom archive URL mapping" do
      let(:path) { path_to_be_archived }

      include_examples "creates custom archive URL mapping"
    end
  end
end
