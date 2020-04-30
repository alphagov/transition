require "rails_helper"
require "transition/import/site_yaml_file"

describe Transition::Import::SiteYamlFile do
  context "A site YAML file" do
    subject(:yaml_file) do
      Transition::Import::SiteYamlFile.load("spec/fixtures/sites/someyaml/ago.yml")
    end

    describe "#abbr" do
      subject { super().abbr }
      it { is_expected.to eql "ago" }
    end

    describe "#whitehall_slug" do
      subject { super().whitehall_slug }
      it { is_expected.to eql "attorney-generals-office" }
    end

    describe "#extra_organisation_slugs" do
      subject { super().extra_organisation_slugs }
      it { is_expected.to eql(["bona-vacantia", "treasury-solicitor-s-office"]) }
    end

    describe "#import!" do
      let(:ago)  { build :organisation, whitehall_slug: "attorney-generals-office" }
      let(:bv)   { build :organisation, whitehall_slug: "bona-vacantia" }
      let(:tsol) { build :organisation, whitehall_slug: "treasury-solicitor-s-office" }

      before do
        allow(Organisation).to receive(:find_by).and_return(ago)
        allow(Organisation).to receive(:where).and_return([bv, tsol])
        yaml_file.import!
      end

      subject(:site) { Site.find_by(abbr: "ago") }

      describe "#tna_timestamp" do
        subject { super().tna_timestamp }
        it { is_expected.to be_a(Time) }
      end

      describe "#homepage" do
        subject { super().homepage }
        it { is_expected.to eql("https://www.gov.uk/government/organisations/attorney-generals-office") }
      end

      describe "#homepage_furl" do
        subject { super().homepage_furl }
        it { is_expected.to eql("www.gov.uk/ago") }
      end

      describe "#organisation" do
        subject { super().organisation }
        it { is_expected.to eql(ago) }
      end

      describe "#extra_organisations" do
        subject { super().extra_organisations }
        it { is_expected.to match_array([bv, tsol]) }
      end

      describe "#global_type" do
        subject { super().global_type }
        it { is_expected.to eql("redirect") }
      end

      describe "#global_new_url" do
        subject { super().global_new_url }
        it { is_expected.to eql("https://www.gov.uk/a-new-world") }
      end

      describe "#global_redirect_append_path" do
        subject { super().global_redirect_append_path }
        it { is_expected.to eql(true) }
      end

      describe "#special_redirect_strategy" do
        subject { super().special_redirect_strategy }
        it { is_expected.to be_nil }
      end

      it "should get hosts including aka hosts" do
        hosts = %w[
          www.attorneygeneral.gov.uk
          aka.attorneygeneral.gov.uk
          www.attorney-general.gov.uk
          aka.attorney-general.gov.uk
          www.ago.gov.uk
          aka.ago.gov.uk
          www.lslo.gov.uk
          aka.lslo.gov.uk
        ]
        expect(site.hosts.pluck(:hostname).sort).to eql(hosts.sort)
      end

      describe "#import! lowercases uppercased hosts" do
        let(:directgov)  { build :organisation, whitehall_slug: "directgov" }

        before do
          allow(Organisation).to receive(:find_by).and_return(directgov)
          Transition::Import::SiteYamlFile.load("spec/fixtures/sites/someyaml/directgov_uppercase.yml").import!
        end

        let(:site) { Site.find_by(abbr: "directgov_uppercase") }

        it "imports the hosts as lowercase" do
          expect(site.hosts.pluck(:hostname)).not_to include("www.DIRECT.gov.uk")
          expect(site.hosts.pluck(:hostname)).to include("www.direct.gov.uk")
        end
      end

      describe "#import! lowercases uppercased aliases" do
        let(:directgov) { build :organisation, whitehall_slug: "directgov" }

        before do
          allow(Organisation).to receive(:find_by).and_return(directgov)
          Transition::Import::SiteYamlFile.load("spec/fixtures/sites/someyaml/directgov_uppercase.yml").import!
        end

        let(:site) { Site.find_by(abbr: "directgov_uppercase") }

        it "imports the aliases as lowercase" do
          expect(site.hosts.pluck(:hostname)).not_to include("MOBILE.DIRECT.gov.uk")
          expect(site.hosts.pluck(:hostname)).to include("mobile.direct.gov.uk")
        end
      end

      describe "updates" do
        before do
          yaml_file.import!
          allow(Organisation).to receive(:where).and_return([tsol])
          Transition::Import::SiteYamlFile.load("spec/fixtures/sites/updates/ago.yml").import!
          Transition::Import::SiteYamlFile.load("spec/fixtures/sites/updates/ago_lslo.yml").import!
        end

        describe "#tna_timestamp" do
          subject { super().tna_timestamp }
          it { is_expected.to be_a(Time) }
        end

        describe "#homepage" do
          subject { super().homepage }
          it { is_expected.to eql("https://www.gov.uk/government/organisations/attorney-update-office") }
        end

        describe "#homepage_title" do
          subject { super().homepage_title }
          it { is_expected.to eql("Now has a &#39;s custom title") }
        end

        describe "#extra_organisations" do
          subject { super().extra_organisations }
          it { is_expected.to match_array([tsol]) }
        end

        describe "#global_type" do
          subject { super().global_type }
          it { is_expected.to be_nil }
        end

        describe "#global_new_url" do
          subject { super().global_new_url }
          it { is_expected.to be_nil }
        end

        describe "#global_redirect_append_path" do
          subject { super().global_redirect_append_path }
          it { is_expected.to eql(false) }
        end

        describe "#special_redirect_strategy" do
          subject { super().special_redirect_strategy }
          it { is_expected.to eql("via_aka") }
        end

        it "should move the host and the aka host to the new site" do
          expect(site.hosts.pluck(:hostname)).not_to include("www.lslo.gov.uk")
          ago_lslo = Site.find_by(abbr: "ago_lslo")
          expect(ago_lslo.hosts.pluck(:hostname)).to match_array(["www.lslo.gov.uk", "aka.lslo.gov.uk"])
        end
      end
    end
  end

  context "A transition YAML file" do
    subject(:transition_yaml_file) do
      Transition::Import::SiteYamlFile.load("spec/fixtures/sites/someyaml/transition-sites/ukti.yml")
    end

    describe "#abbr" do
      subject { super().abbr }
      it { is_expected.to eql "ukti" }
    end

    describe "#whitehall_slug" do
      subject { super().whitehall_slug }
      it { is_expected.to eql "uk-trade-investment" }
    end
  end
end
