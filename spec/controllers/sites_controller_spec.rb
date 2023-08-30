require "rails_helper"

describe SitesController do
  let(:site)    { create :site, abbr: "moj" }
  let(:gds_bob) { create(:gds_editor, name: "Bob Terwhilliger") }
  let(:site_manager) { create(:site_manager) }

  describe "#new" do
    let(:organisation) { create(:organisation) }

    before { login_as site_manager }

    it "returns a success response" do
      get :new, params: { organisation_id: organisation.whitehall_slug }

      expect(response.status).to eql(200)
    end

    context "when the user does not have permission" do
      def make_request
        get :new, params: { organisation_id: organisation.whitehall_slug }
      end

      it_behaves_like "disallows editing by non-Site managers"
    end
  end

  describe "#create" do
    let(:organisation) { create(:organisation) }
    let(:params) { attributes_for(:site_form) }

    before { login_as site_manager }

    it "returns a success response" do
      post :create, params: { organisation_id: organisation.whitehall_slug, site_form: params }

      expect(response.status).to eql(200)
    end

    context "when the user does not have permission" do
      def make_request
        post :create, params: { organisation_id: organisation.whitehall_slug, site_form: params }
      end

      it_behaves_like "disallows editing by non-Site managers"
    end
  end

  describe "#edit" do
    context "when the user does have permission" do
      before do
        login_as gds_bob
      end

      it "displays the form" do
        get :edit, params: { id: site.abbr }
        expect(response.status).to eql(200)
      end
    end

    context "when the user does not have permission" do
      def make_request
        get :edit, params: { id: site.abbr }
      end

      it_behaves_like "disallows editing by non-GDS Editors"
    end
  end

  describe "#confirm_destroy" do
    context "when the user does have permission" do
      before { login_as site_manager }

      it "displays the form" do
        get :confirm_destroy, params: { id: site.abbr }
        expect(response.status).to eql(200)
      end
    end

    context "when the user does not have permission" do
      before { login_as stub_user }

      it "disallows deleting by non-Site Managers" do
        get :confirm_destroy, params: { id: site.abbr }
        expect(response.status).to eql(302)
      end
    end
  end
end
