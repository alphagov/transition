require "rails_helper"
require "transition/import/orgs_sites_hosts"

describe Transition::Import::OrgsSitesHosts do
  describe ".from_yaml!" do
    context "there are no valid yaml files" do
      it "reports the lack" do
        expect {
          Transition::Import::OrgsSitesHosts.from_yaml!(
            "spec/fixtures/sites/noyaml/*.yml",
            Transition::Import::WhitehallOrgs.new("spec/fixtures/whitehall/orgs_abridged.yml"),
          )
        }.to raise_error(Transition::Import::Sites::NoYamlFound)
      end
    end

    context "importing valid yaml files", testing_before_all: true do
      before :all do
        Transition::Import::OrgsSitesHosts.from_yaml!(
          "spec/fixtures/sites/someyaml/**/*.yml",
          Transition::Import::WhitehallOrgs.new("spec/fixtures/whitehall/orgs_abridged.yml"),
        )
        @ukti = Site.find_by(abbr: "ukti")
      end

      it "has imported orgs" do
        expect(Organisation.count).to eq(6)
      end

      it "has imported sites" do
        expect(Site.count).to eq(8)
      end

      it "has imported hosts" do
        expect(Host.count).to eq(12 * 2) # 12 hosts plus 12 aka hosts
      end

      describe "a child organisation with its own hosted site" do
        let(:bis) { Organisation.find_by! whitehall_slug: "department-for-business-innovation-skills" }

        subject { Organisation.find_by! whitehall_slug: "uk-atomic-energy-authority" }

        it "has 1 site" do
          expect(subject.sites.size).to eq(1)
        end

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
          Transition::Import::OrgsSitesHosts.from_yaml!(
            "spec/fixtures/sites/someyaml/*.yml",
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
