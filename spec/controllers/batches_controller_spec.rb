require "rails_helper"

describe BatchesController do
  describe "GET #show" do
    let(:user) { create(:user) }
    let(:site) { create(:site) }

    context "when batch exists" do
      let(:mappings_batch) { create(:bulk_add_batch, site: site, user: user) }

      before do
        login_as(user)
        get :show, params: { site_id: site.abbr, id: mappings_batch.id }
        @parsed_response = JSON.parse(response.body)
      end

      it "responds with the correct HTTP status code" do
        expect(response.status).to be(200)
      end

      it "renders a JSON document" do
        expected = {
          "done" => 0,
          "total" => 2,
          "past_participle" => "added",
        }
        expect(@parsed_response).to eq(expected)
      end
    end

    context "when batch does not exist" do
      before do
        login_as(user)
        get :show, params: { site_id: site.abbr, id: 72 }
      end

      it "responds with a 404 status code" do
        expect(response.status).to be(404)
      end
    end
  end
end
