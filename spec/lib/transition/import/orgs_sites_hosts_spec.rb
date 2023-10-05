require "rails_helper"
require "transition/import/orgs_sites_hosts"

describe Transition::Import::Organisations do
  describe ".from_yaml!" do
    context "importing valid yaml files", testing_before_all: true do
      before :all do
        Transition::Import::Organisations.from_yaml!(
          Transition::Import::WhitehallOrgs.new("spec/fixtures/whitehall/orgs_abridged.yml"),
        )
        @ukti = Site.find_by(abbr: "ukti")
      end

      it "has imported orgs" do
        expect(Organisation.count).to eq(6)
      end

      describe "a child organisation with its own hosted site" do
        let(:bis) { Organisation.find_by! whitehall_slug: "department-for-business-innovation-skills" }

        subject { Organisation.find_by! whitehall_slug: "uk-atomic-energy-authority" }

        describe "#parent_organisations" do
          subject { super().parent_organisations }
          it { is_expected.to match_array([bis]) }
        end

        describe "#abbreviation" do
          subject { super().abbreviation }
          it { is_expected.to eql "UKAEA" }
        end

        describe "#whitehall_type" do
          subject { super().whitehall_type }
          it { is_expected.to eql "Executive non-departmental public body" }
        end
      end

      context "the import is run again" do
        before :all do
          Transition::Import::Organisations.from_yaml!(
            Transition::Import::WhitehallOrgs.new("spec/fixtures/whitehall/orgs_abridged.yml"),
          )
        end

        describe "a pre-existing parent-child relationship is not duplicated" do
          let(:bis) { Organisation.find_by! whitehall_slug: "department-for-business-innovation-skills" }

          subject { Organisation.find_by! whitehall_slug: "uk-atomic-energy-authority" }

          describe "#parent_organisations" do
            subject { super().parent_organisations }
            it { is_expected.to match_array([bis]) }
          end
        end
      end
    end
  end
end
