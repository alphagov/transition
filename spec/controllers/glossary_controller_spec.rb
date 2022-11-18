require "rails_helper"

describe GlossaryController do
  describe "#index" do
    render_views

    before do
      site = create(:site, abbr: "cabinetoffice")
      create(:archived, site:)
      create(:redirect, site:, path: "/interesting-news-story", new_url: "https://www.gov.uk/new-url-for-interesting-news-story")

      login_as_stub_user
      get :index
    end

    context "loading the page" do
      it "responds with the correct HTTP status code" do
        expect(response.status).to be(200)
      end

      it "includes details of the example site" do
        expect(response.body).to include("http://cabinetoffice.gov.uk/interesting-news-story")
        expect(response.body).to include("redirects to")
        expect(response.body).to include("https://www.gov.uk/new-url-for-interesting-news-story")
      end
    end
  end
end
