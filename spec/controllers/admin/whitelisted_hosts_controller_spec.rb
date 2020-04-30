require "rails_helper"

describe Admin::WhitelistedHostsController do
  let(:normal_user) { create(:user, permissions: %w[signin]) }
  let(:admin_user) { create(:user, permissions: %w[admin signin]) }

  shared_examples "denies access if you are not an admin" do
    before do
      login_as(normal_user)
      make_request
    end

    it "redirects to the homepage" do
      expect(response).to redirect_to("/")
    end

    it "sets a flash message" do
      expect(flash[:alert]).to include("Only admins can access that.")
    end
  end

  describe "#index", versioning: true do
    specify { expect(PaperTrail).to be_enabled }

    def make_request
      get :index
    end

    render_views

    it_behaves_like "denies access if you are not an admin"

    context "logged in as admin" do
      before do
        login_as(admin_user)
        PaperTrail.request.whodunnit = admin_user.name
        create(:whitelisted_host, hostname: "a")
        create(:whitelisted_host, hostname: "b")
        make_request
      end

      it "should display whodunnit in the table" do
        originator = assigns(:whitelisted_hosts).first.paper_trail.originator
        expect(response.body).to match(/#{originator}/im)
      end

      it "lists the whitelisted_hosts" do
        expect(assigns(:whitelisted_hosts).size).to eq(2)
      end
    end
  end

  describe "#new" do
    def make_request
      get :new
    end

    it_behaves_like "denies access if you are not an admin"
  end

  describe "#create" do
    def make_request
      post :create, params: { whitelisted_host: { hostname: "a.com" } }
    end

    it_behaves_like "denies access if you are not an admin"

    context "logged in as admin" do
      before do
        login_as(admin_user)
        make_request
      end

      it "should redirect to the index" do
        expect(response).to redirect_to("/admin/whitelisted_hosts")
      end

      it "should set a success message" do
        expect(flash[:success]).to eq("a.com added to whitelist.")
      end

      it "should create the host" do
        expect(WhitelistedHost.find_by(hostname: "a.com")).not_to be_nil
      end

      context "with an invalid hostname" do
        def make_request
          post :create, params: { whitelisted_host: { hostname: "a}b.com" } }
        end

        it "should rerender the form" do
          expect(response).to have_rendered "admin/whitelisted_hosts/new"
        end
      end
    end
  end
end
