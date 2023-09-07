require "rails_helper"

describe SitesController do
  let(:site)    { create :site, abbr: "moj" }
  let(:gds_bob) { create(:gds_editor, name: "Bob Terwhilliger") }

  describe "#new" do
    let(:organisation) { create(:organisation) }

    before { login_as gds_bob }

    it "returns a success response" do
      get :new, params: { organisation_id: organisation.whitehall_slug }

      expect(response.status).to eql(200)
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
end
