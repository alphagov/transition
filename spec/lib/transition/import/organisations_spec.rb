require "rails_helper"
require "transition/import/organisations"
require "transition/import/sites"

describe Transition::Import::Organisations do
  describe ".from_whitehall!", testing_before_all: true do
    before :all do
      Transition::Import::Organisations.from_whitehall!(
        Transition::Import::WhitehallOrgs.new("spec/fixtures/whitehall/orgs_abridged.yml"),
      )
    end

    it "has imported orgs - one per org in orgs_abridged.yml" do
      expect(Organisation.count).to eq(6)
    end

    describe "an organisation with multiple parents" do
      let(:bis) { Organisation.find_by(whitehall_slug: "department-for-business-innovation-skills") }
      let(:fco) { Organisation.find_by(whitehall_slug: "foreign-commonwealth-office") }

      subject(:ukti) { Organisation.find_by(whitehall_slug: "uk-trade-investment") }

      describe "#abbreviation" do
        subject { super().abbreviation }
        it { is_expected.to eql "UKTI" }
      end

      describe "#content_id" do
        subject { super().content_id }
        it { is_expected.to eql "8ded75c7-29ea-4831-958c-4f07fd73425d" }
      end

      describe "#whitehall_slug" do
        subject { super().whitehall_slug }
        it { is_expected.to eql "uk-trade-investment" }
      end

      describe "#whitehall_type" do
        subject { super().whitehall_type }
        it { is_expected.to eql "Non-ministerial department" }
      end

      describe "#homepage" do
        subject { super().homepage }
        it { is_expected.to eql "https://www.gov.uk/government/organisations/uk-trade-investment" }
      end

      describe "#parent_organisations" do
        subject { super().parent_organisations }
        it { is_expected.to match_array([bis, fco]) }
      end
    end

    describe "fudged CSS/URL details" do
      subject(:ago) { Organisation.find_by(whitehall_slug: "attorney-generals-office") }

      describe "#css" do
        subject { super().css }
        it { is_expected.to eql "attorney-generals-office" }
      end

      describe "#furl" do
        subject { super().furl }
        it { is_expected.to eql "www.gov.uk/ago" }
      end
    end
  end
end
