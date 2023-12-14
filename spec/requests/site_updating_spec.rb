require "rails_helper"

describe "Site updating" do
  render_views

  let!(:site_manager) { create(:site_manager) }
  let!(:organisation) { create(:organisation, whitehall_slug: "air-accidents-investigation-branch") }
  let!(:alias_host) { create(:host, hostname: "aaib.gov.uk", site:) }
  let(:site) { create(:site) }
  let(:params) do
    attributes_for(:site_form,
                   :with_optional_fields,
                   :with_aliases,
                   site_id: site.id,
                   organisation_slug: "air-accidents-investigation-branch")
  end

  it "redirects to the site path" do
    put site_path(site), params: { site_form: params }

    expect(response).to redirect_to(site_path(site.reload))
  end

  it "updates the existing site" do
    put site_path(site), params: { site_form: params }

    attributes = {
      global_new_url: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch/about",
      global_redirect_append_path: true,
      global_type: "redirect",
      homepage: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch",
      homepage_furl: "www.gov.uk/aaib",
      homepage_title: "Air accidents investigation branch",
      query_params: "file",
      special_redirect_strategy: "via_aka",
      tna_timestamp: Time.strptime("20141104112824", "%Y%m%d%H%M%S"),
    }

    site.reload
    expect(site.attributes.with_indifferent_access).to include attributes
    expect(site.organisation).to eq organisation
  end

  it "updates related hosts and aka hosts" do
    put site_path(site), params: { site_form: params }

    alias_site_1 = Host.where(hostname: "www.aaib.gov.uk")
    alias_site_2 = Host.where(hostname: "aaib.gov.uk")
    alias_site_3 = Host.where(hostname: "aaib.com")

    expect(site.reload.hosts.count).to be 6
    expect(alias_site_1).to exist
    expect(alias_site_2).to exist
    expect(alias_site_3).to exist
    expect(Host.where(hostname: "aka.aaib.gov.uk", canonical_host: alias_site_1)).to exist
    expect(Host.where(hostname: "aka-aaib.gov.uk", canonical_host: alias_site_2)).to exist
    expect(Host.where(hostname: "aka-aaib.com", canonical_host: alias_site_3)).to exist
  end

  context "when there are existing hosts" do
    let!(:alias_host) { create(:host, hostname: "alias_host.gov.uk", site:) }

    it "removes hosts which aren't submitted" do
      put site_path(site), params: { site_form: params }

      expect(site.reload.hosts.count).to be 6
      expect(Host.where(hostname: "alias_host.gov.uk")).to_not exist
    end
  end

  context "with extra organisations" do
    let!(:extra_organisation) { create(:organisation, whitehall_slug: "the-adjudicator-s-office", title: "The adjudicator's office") }
    let!(:extra_organisation_2) { create(:organisation, whitehall_slug: "government-digital-service", title: "Government digital service") }
    let(:params) { attributes_for(:site_form, extra_organisations: [extra_organisation.id, extra_organisation_2.id]) }

    it "creates extra organisations" do
      put site_path(site), params: { site_form: params }

      expect(Site.last.extra_organisations.count).to be 2
      expect(Site.last.extra_organisations.where(title: "The adjudicator's office")).to exist
      expect(Site.last.extra_organisations.where(title: "Government digital service")).to exist
    end
  end

  context "with blank optional fields" do
    let(:params) { attributes_for(:site_form, :with_blank_optional_fields, site_id: site.id) }

    it "nullifies blanks when creating the new site" do
      put site_path(site), params: { site_form: params }

      attributes = {
        homepage: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch",
        tna_timestamp: Time.strptime("20141104112824", "%Y%m%d%H%M%S"),
        global_redirect_append_path: false,
        global_new_url: nil,
        special_redirect_strategy: nil,
        global_type: nil,
        homepage_title: nil,
        homepage_furl: nil,
        query_params: "",
      }

      site.reload
      expect(site.attributes.with_indifferent_access).to include attributes
      expect(site.organisation).to eq organisation
    end
  end
end
