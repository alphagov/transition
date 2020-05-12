require "rails_helper"
require "transition/import/whitehall/mappings_csv"

describe Transition::Import::Whitehall::MappingsCSV do
  def csv_for(old_path, govuk_path, whitehall_state = "published")
    StringIO.new(<<~CSV)
      Old URL,New URL,Admin URL,State
      http://dft.gov.uk#{old_path},https://www.gov.uk#{govuk_path},http://whitehall-admin/#{rand(1000)},#{whitehall_state}
    CSV
  end

  describe "from_csv" do
    let(:as_user) { create(:user, name: "C-3PO", is_robot: true) }

    context "site and host exists" do
      let!(:site) { create(:site, abbr: "dft", query_params: "significant") }

      before do
        Transition::Import::Whitehall::MappingsCSV.new(as_user).from_csv(csv)
      end

      context "rosy case" do
        let(:csv) { csv_for("/oldurl", "/new") }

        subject(:mapping) { Mapping.first }

        specify { expect(Mapping.count).to eq(1) }

        describe "#site" do
          subject { super().site }
          it { is_expected.to eq(site) }
        end

        describe "#path" do
          subject { super().path }
          it { is_expected.to eq("/oldurl") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/new") }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end
      end

      context "Old URL is not canonical, no mapping" do
        let(:csv) { csv_for("/oldurl?significant=aha&ignored=ohyes", "/new") }

        subject(:mapping) { Mapping.first }

        specify { expect(Mapping.count).to eq(1) }

        describe "#site" do
          subject { super().site }
          it { is_expected.to eq(site) }
        end

        describe "#path" do
          subject { super().path }
          it { is_expected.to eq("/oldurl?significant=aha") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/new") }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end
      end

      context "existing mapping and the Old URL is not canonical" do
        let(:mapping) { create(:mapping, site: site, path: "/oldurl?significant=aha", new_url: "https://www.gov.uk/mediocre") }
        let(:csv) { csv_for("/oldurl?significant=aha&ignored=ohyes", "/amazing") }

        subject(:mapping) { Mapping.first }

        specify { expect(Mapping.count).to eq(1) }

        describe "#site" do
          subject { super().site }
          it { is_expected.to eq(site) }
        end

        describe "#path" do
          subject { super().path }
          it { is_expected.to eq("/oldurl?significant=aha") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/amazing") }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end
      end

      context "existing redirect mapping edited by a human" do
        let(:csv) do
          create(:redirect, from_redirector: true, site: site, path: "/oldurl", new_url: "https://www.gov.uk/curated")
          csv_for("/oldurl", "/automated")
        end

        subject(:mapping) { Mapping.first }

        specify { expect(Mapping.count).to eq(1) }

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/curated") }
        end
      end

      context "existing archive mapping edited by a human" do
        let(:csv) do
          create(:archived, from_redirector: true, site: site, path: "/oldurl")
          csv_for("/oldurl", "/automated")
        end

        subject(:mapping) { Mapping.first }

        specify { expect(Mapping.count).to eq(1) }

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/automated") }
        end
      end

      context "existing unresolved mapping edited by a human" do
        let(:csv) do
          create(:unresolved, from_redirector: true, site: site, path: "/oldurl")
          csv_for("/oldurl", "/automated")
        end

        subject(:mapping) { Mapping.first }

        specify { expect(Mapping.count).to eq(1) }

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end

        describe "#new_url" do
          subject { super().new_url }
          it { is_expected.to eq("https://www.gov.uk/automated") }
        end
      end

      context "CSV row without an Old URL" do
        let(:csv) do
          StringIO.new(<<~CSV)
            Old URL,New URL,Admin URL,State
            ,https://www.gov.uk/a-document,http://whitehall-admin/#{rand(1000)},published
          CSV
        end

        specify { expect(Mapping.count).to eq(0) }
      end

      context 'row has a State which isn\'t "published"' do
        let(:csv) { csv_for("/oldurl", "/new", "draft") }

        specify { expect(Mapping.all.count).to eq(0) }
      end

      context "Old URL is unparseable" do
        let(:csv) do
          StringIO.new(<<~CSV)
            Old URL,New URL,Admin URL,State
            http://_____/old,https://www.gov.uk/a-document,http://whitehall-admin/#{rand(1000)},published
          CSV
        end

        specify { expect(Mapping.all.count).to eq(0) }
      end
    end

    context "testing version recording", versioning: true do
      let!(:site) { create(:site, abbr: "dft", query_params: "significant") }
      let(:csv) { csv_for("/oldurl", "/new") }

      before do
        Transition::Import::Whitehall::MappingsCSV.new(as_user).from_csv(csv)
      end

      subject(:mapping) { Mapping.first }

      specify "records the changes being made by a robot user" do
        expect(mapping.versions.size).to eq(1)
        expect(mapping.versions.first.whodunnit).to eq(as_user.name)
        expect(mapping.versions.first.user_id).to eq(as_user.id)
      end

      specify "reverts the whodunnit user" do
        expect(::PaperTrail.request.whodunnit).to be_nil
      end
    end

    context "no site/host for Old URL" do
      let(:csv) { csv_for("/oldurl", "/amazing") }

      it "logs an unknown host" do
        expect(Rails.logger).to receive(:warn).with("Skipping mapping for unknown host in Whitehall URL CSV: 'dft.gov.uk'")
        Transition::Import::Whitehall::MappingsCSV.new(as_user).from_csv(csv)
      end
    end
  end
end
