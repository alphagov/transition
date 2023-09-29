require "rails_helper"

describe SiteDatesController do
  let(:site)    { create :site, abbr: "moj" }
  let(:gds_bob) { create(:gds_editor, name: "Bob Terwhilliger") }

  describe "#new" do
    context "when the user does have permission" do
      before do
        login_as gds_bob
      end

      it "displays the form" do
        get :edit, params: { site_id: site.abbr }
        expect(response.status).to eql(200)
      end
    end

    context "when the user does not have permission" do
      def make_request
        get :edit, params: { site_id: site.abbr }
      end

      it_behaves_like "disallows editing by non-GDS Editors"
    end
  end
end
