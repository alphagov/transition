require "rails_helper"

describe StyleController do
  describe "#index" do
    render_views

    before do
      login_as_stub_user
      get :index
    end

    context "loading the page" do
      it "responds with the correct HTTP status code" do
        expect(response.status).to be(200)
      end
    end
  end
end
