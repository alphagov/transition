require "rails_helper"

describe VersionsController, versioning: true do
  describe "#index" do
    render_views

    specify { expect(PaperTrail).to be_enabled }

    let(:site) { create(:site, abbr: "cabinetoffice") }
    let(:mapping) { create(:redirect, site:, path: "/interesting-news-story", new_url: "https://www.gov.uk/new-url-for-interesting-news-story", as_user: stub_user) }

    context "loading the page" do
      before do
        login_as_stub_user
        get :index, params: { mapping_id: mapping.id, site_id: site.id }
      end

      it "responds with the correct HTTP status code" do
        expect(response.status).to be(200)
      end

      it "shows details of the creation" do
        expect(response.body).to include("Mapping created")
        expect(response.body).to include("&lt;blank&gt; → /interesting-news-story")
        expect(response.body).to include("&lt;blank&gt; → https://www.gov.uk/new-url-for-interesting-news-story")
        expect(response.body).to include("&lt;blank&gt; → Redirect")
      end
    end

    context "when the mapping is updated" do
      before do
        Transition::History.as_a_user(stub_user) do
          mapping.update!(new_url: "https://www.gov.uk/new-redirect-path")
          mapping.reload
        end
        login_as_stub_user
        get :index, params: { mapping_id: mapping.id, site_id: site.id }
      end

      it "shows details of the update when a mapping is amended" do
        expect(response.body).to include("New URL")
        expect(response.body).to include("https://www.gov.uk/new-url-for-interesting-news-story → https://www.gov.uk/new-redirect-path")
      end
    end
  end
end
