require "rails_helper"
require "transition/import/whitehall_orgs"
require "gds_api/test_helpers/organisations"

describe Transition::Import::WhitehallOrgs do
  context "with an API response stubbed to fixtures" do
    subject(:whitehall_orgs) do
      described_class.new("spec/fixtures/whitehall/orgs_abridged.yml")
    end

    it "has 6 organisations" do
      expect(subject.organisations.size).to eq(6)
    end

    describe "#by_id" do
      subject(:ago) do
        whitehall_orgs.by_id[
          "https://whitehall-admin.production.alphagov.co.uk/api/organisations/attorney-generals-office"
        ]
      end

      it      { is_expected.to be_a(Hash) }
      specify { expect(ago["format"]).to eq("Ministerial department") }

      describe "#details" do
        subject { super()["details"] }
        describe "#slug" do
          subject { super()["slug"] }
          it { is_expected.to eq("attorney-generals-office") }
        end
      end
    end
  end

  context "with the real API" do
    include GdsApi::TestHelpers::Organisations

    subject(:whitehall_orgs) { described_class.new }

    context "when there are some organisations in the API" do
      before do
        stub_organisations_api_has_organisations %w[ministry-of-funk department-of-soul hm-rock-and-roll]
      end

      it "extracts all the organisations from the API" do
        expect(subject.organisations.size).to eq(3)
      end
    end

    context "when there are so many organisations in the API that it paginates" do
      before do
        # The default pagination is 20, so make 21 to trigger this
        stub_organisations_api_has_organisations %w[
          ministry-of-funk-1
          department-of-soul-1
          hm-rock-and-roll-1
          ministry-of-funk-2
          department-of-soul-2
          hm-rock-and-roll-2
          ministry-of-funk-3
          department-of-soul-3
          hm-rock-and-roll-3
          ministry-of-funk-4
          department-of-soul-4
          hm-rock-and-roll-4
          ministry-of-funk-5
          department-of-soul-5
          hm-rock-and-roll-5
          ministry-of-funk-6
          department-of-soul-6
          hm-rock-and-roll-6
          ministry-of-funk-7
          department-of-soul-7
          hm-rock-and-roll-7
        ]
      end

      it "extracts all organisations from each page of the API" do
        expect(subject.organisations.size).to eq(21)
      end
    end
  end
end
