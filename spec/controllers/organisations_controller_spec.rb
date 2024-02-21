require "rails_helper"

describe OrganisationsController do
  describe "#index" do
    let!(:organisation_z) { create :organisation, :with_site, title: "Zzzzzz" }
    let!(:organisation_a) { create :organisation, :with_site, title: "Aaaaaa" }

    before do
      login_as_stub_user
      get :index
    end

    it "orders organisations alphabetically" do
      expect(assigns(:organisations)).to eq([organisation_a, organisation_z])
    end
  end

  describe "#show" do
    render_views

    let(:organisation) { create(:organisation, title: "HM Government Department") }

    before do
      create(:site, abbr: "site-2", organisation:)
      create(:site, abbr: "site-1", organisation:)
      login_as_stub_user
      get :show, params: { id: organisation.whitehall_slug }
    end

    it "responds with the correct HTTP status code" do
      expect(response.status).to be(200)
    end

    it "lists the sites for the organisation in order of default hostname" do
      expect(response.body).to include("site-1.gov.uk")
      expect(response.body).to include("site-2.gov.uk")

      expect(response.body.index("site-1.gov.uk")).to be < response.body.index("site-2.gov.uk")
    end
  end
end
