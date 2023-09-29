require "rails_helper"

describe SitesController do
  let(:site)    { create :site, abbr: "moj" }
  let(:gds_bob) { create(:gds_editor, name: "Bob Terwhilliger") }
  let(:site_manager) { create(:site_manager, name: "Boss McSitemanagery") }

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

    context "with versioning", versioning: true do
      it "records the user who created the site" do
        post :create, params: { organisation_id: organisation.whitehall_slug, site_form: params }

        last_version = site.versions.last

        expect(last_version.event).to eql("create")
        expect(last_version.whodunnit).to eql("Boss McSitemanagery")
        expect(last_version.user_id).to eql(site_manager.id)
      end
    end

    context "when the user does not have permission" do
      def make_request
        post :create, params: { organisation_id: organisation.whitehall_slug, site_form: params }
      end

      it_behaves_like "disallows editing by non-Site managers"
    end
  end

  describe "#edit" do
    let(:organisation) { create(:organisation) }

    context "when the user does have permission" do
      before do
        login_as site_manager
      end

      it "displays the form" do
        get :edit, params: { id: site.abbr }
        expect(response.status).to eql(200)
      end
    end

    context "when the user does not have permission" do
      before { login_as stub_user }

      def make_request
        get :edit, params: { organisation_id: organisation.whitehall_slug, id: site.abbr }
      end

      it "disallows deleting by non-Site Managers" do
        make_request
        expect(response.status).to eql(302)
      end
    end
  end

  describe "#update" do
    let(:organisation) { create(:organisation) }
    let(:params) do
      attributes_for(
        :site_form,
        site_id: site.id,
        organisation_slug: organisation.whitehall_slug,
      )
    end

    def make_request
      post :update, params: {
        id: site.abbr,
        site_form: params,
      }
    end

    context "with versioning", versioning: true do
      before { login_as site_manager }

      it "records the user who updated the site" do
        make_request

        last_version = site.versions.last

        expect(last_version.event).to eql("update")
        expect(last_version.whodunnit).to eql("Boss McSitemanagery")
        expect(last_version.user_id).to eql(site_manager.id)
      end
    end

    context "when the user does not have permission" do
      before { login_as stub_user }

      it "disallows editing" do
        make_request

        expect(response).to redirect_to site_path(site)
        expect(flash[:alert]).to eql("Only Site Managers can access that.")
      end
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
      def make_request
        get :confirm_destroy, params: { id: site.abbr }
      end

      it_behaves_like "disallows deleting by non-Site managers"
    end
  end

  describe "#destroy" do
    def make_request
      post :destroy, params: { id: site.abbr, delete_site_form: { abbr_confirmation: site.abbr } }
    end

    context "when the user does have permission" do
      before { login_as site_manager }

      context "with versioning", versioning: true do
        it "records the user who updated the site" do
          make_request

          last_version = site.versions.last

          expect(last_version.event).to eql("destroy")
          expect(last_version.whodunnit).to eql("Boss McSitemanagery")
          expect(last_version.user_id).to eql(site_manager.id)
        end
      end
    end

    context "when the user does not have permission" do
      it_behaves_like "disallows deleting by non-Site managers"
    end
  end
end
