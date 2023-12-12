require "rails_helper"

describe SiteForm do
  describe "validations" do
    it "surfaces errors on the site model" do
      site_form = build(:site_form, tna_timestamp: nil)

      expect(site_form.valid?).to be false
      expect(site_form.errors[:tna_timestamp]).to include("Enter a TNA Timestamp")
    end

    it "surfaces errors on the default host model" do
      site_form = build(:site_form, hostname: nil)

      expect(site_form.valid?).to be false
      expect(site_form.errors[:hostname]).to include("Enter a hostname")
    end

    describe "#aliases" do
      context "when there is a validation error on an alias host" do
        it "adds the error message to the errors" do
          site_form = build(:site_form, aliases: "aaib.gov.uk,,aaib.com")

          expect(site_form.valid?).to be false
          expect(site_form.errors[:aliases]).to include("Enter a hostname")
        end
      end

      context "when the list contains duplicates" do
        it "adds the error message and problematic hostname to the errors" do
          site_form = build(:site_form, aliases: "aaib.gov.uk,aaib.gov.uk")

          expect(site_form.valid?).to be false
          expect(site_form.errors[:aliases]).to include("Hostnames must be unique")
        end
      end
    end
  end

  describe ".for_existing" do
    let!(:alias_host) { create(:host, hostname: "alias_host.gov.uk", site:) }
    let!(:second_alias_host) { create(:host, hostname: "second_alias_host.gov.uk", site:) }
    let(:extra_organisation) { create(:organisation, whitehall_slug: "extra-organisation") }
    let(:site) do
      create(:site,
             extra_organisations: [extra_organisation],
             homepage_title: "Homepage title",
             homepage_furl: "www.gov.uk/site",
             global_type: Site::GLOBAL_TYPES[:redirect],
             global_new_url: "global-new-url",
             global_redirect_append_path: true,
             query_params: "site",
             special_redirect_strategy: Site::SPECIAL_REDIRECT_STRATEGY_TYPES[:via_aka])
    end

    it "returns a populated site form" do
      site_form = SiteForm.for_existing(site.reload)

      expect(site_form).to have_attributes(
        organisation_slug: site.organisation.whitehall_slug,
        abbr: site.abbr,
        tna_timestamp: "20120816224015",
        homepage: "https://www.gov.uk/government/organisations/example-org",
        extra_organisations: [extra_organisation.id],
        homepage_title: "Homepage title",
        homepage_furl: "www.gov.uk/site",
        global_type: "redirect",
        global_new_url: "global-new-url",
        global_redirect_append_path: true,
        query_params: "site",
        special_redirect_strategy: "via_aka",
        hostname: site.default_host.hostname,
        aliases: "alias_host.gov.uk,second_alias_host.gov.uk",
      )
    end
  end

  describe "#organisations" do
    let!(:organisation) { create(:organisation, whitehall_slug: organisation_slug) }
    let!(:other_organisation) { create(:organisation, whitehall_slug: "the-adjudicator-s-office", title: "The adjudicator's office") }
    let(:organisation_slug) { "air-accidents-investigation-branch" }

    it "returns all organisation except the current organisation" do
      site_form = build(:site_form, organisation_slug:)

      expect(site_form.organisations.length).to be 1
      expect(site_form.organisations.last).to eq other_organisation
    end
  end

  describe "#save" do
    let!(:organisation) { create(:organisation, whitehall_slug: organisation_slug) }
    let(:organisation_slug) { "air-accidents-investigation-branch" }

    context "when invalid" do
      it "returns false" do
        site_form = build(:site_form, tna_timestamp: nil)

        expect(site_form.save).to be false
      end
    end

    it "returns an instance of the new Site" do
      site_form = build(:site_form)

      site = site_form.save

      expect(site).to be_a Site
      expect(site).to have_attributes(
        abbr: "aaib",
        organisation:,
        homepage: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch",
        tna_timestamp: Time.strptime("20141104112824", "%Y%m%d%H%M%S"),
      )
    end

    it "creates the default host and aka host" do
      site_form = build(:site_form)

      site = site_form.save

      site.hosts.reload
      expect(site.hosts.count).to be 2
      expect(site.hosts.first.hostname).to eq "www.aaib.gov.uk"
      expect(site.hosts.last.hostname).to eq "aka.aaib.gov.uk"
    end

    context "with optional fields" do
      it "returns an instance of the new Site" do
        site_form = build(:site_form, :with_optional_fields)

        site = site_form.save

        expect(site).to be_a Site
        expect(site).to have_attributes(
          homepage_title: "Air accidents investigation branch",
          homepage_furl: "www.gov.uk/aaib",
          global_type: "redirect",
          global_new_url: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch/about",
          global_redirect_append_path: true,
          query_params: "file",
          special_redirect_strategy: "via_aka",
        )
      end
    end

    context "with a comma-separated list of alias hosts" do
      it "creates the alias hosts and aka hosts" do
        site_form = build(:site_form, :with_aliases)

        site = site_form.save

        alias_site_1 = site.hosts.where(hostname: "aaib.gov.uk")
        alias_site_2 = site.hosts.where(hostname: "aaib.com")

        expect(alias_site_1).to exist
        expect(alias_site_2).to exist
        expect(site.hosts.where(hostname: "aka-aaib.gov.uk", canonical_host: alias_site_1)).to exist
        expect(site.hosts.where(hostname: "aka-aaib.com", canonical_host: alias_site_2)).to exist
      end
    end

    context "with extra organisations" do
      let!(:extra_organisation) { create(:organisation, whitehall_slug: "the-adjudicator-s-office", title: "The adjudicator's office") }
      let!(:extra_organisation_2) { create(:organisation, whitehall_slug: "government-digital-service", title: "Government digital service") }

      it "creates extra organisations" do
        site_form = build(:site_form, extra_organisations: [extra_organisation.id, extra_organisation_2.id])

        site = site_form.save

        expect(site.extra_organisations.count).to be 2
        expect(site.extra_organisations.where(title: "The adjudicator's office")).to exist
        expect(site.extra_organisations.where(title: "Government digital service")).to exist
      end
    end
  end
end
