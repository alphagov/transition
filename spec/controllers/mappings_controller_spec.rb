require "rails_helper"
require "csv"

describe MappingsController do
  let(:site)       { create :site, abbr: "moj" }
  let(:batch)      { create(:bulk_add_batch, site: site) }
  let(:gds_bob)    { create(:gds_editor, name: "Bob Terwhilliger") }
  let(:admin_user) { create(:user, permissions: %w[admin signin]) }
  let(:mapping)    { create(:mapping, site: site, as_user: gds_bob) }

  describe "#index" do
    before do
      login_as_stub_user
    end

    describe "sorting" do
      let(:site) { create :site, :with_mappings_and_hits }

      context "in the absence of a sort parameter" do
        it "orders mappings by path" do
          # this would be last in insertion order, but first alphabetically
          create(:mapping, site: site, path: "/..")
          get :index, params: { site_id: site.abbr }

          expect(assigns(:mappings).to_a).to eq(site.mappings.order(:path).to_a)
        end
      end

      context "when sorting by hits" do
        it "orders mappings by hit count" do
          get :index, params: { site_id: site.abbr, sort: "by_hits" }

          expect(assigns(:mappings).to_a).to eq(
            site.mappings.order("hit_count DESC").to_a,
          )
        end
      end
    end

    describe "filtering" do
      let!(:mapping_a) { create :redirect, path: "/a", new_url: "http://f.gov.uk/1", site: site }
      let!(:mapping_b) { create :redirect, path: "/b", new_url: "http://f.gov.uk/2", site: site }
      let!(:mapping_c) { create :redirect, path: "/c", new_url: "http://f.gov.uk/3", site: site }

      it "filters mappings by path" do
        get :index, params: { site_id: site.abbr, path_contains: "a" }
        expect(assigns(:mappings)).to eq([mapping_a])
      end

      it "canonicalizes filter input" do
        get :index, params: { site_id: site.abbr, path_contains: "/A?q=1" }
        expect(assigns(:mappings)).to eq([mapping_a])
      end

      it "filters mappings by new_url" do
        get :index, params: { site_id: site.abbr, new_url_contains: "f.gov.uk/1" }
        expect(assigns(:mappings)).to eq([mapping_a])
      end

      it "ignores non-redirect mappings when filtering by new_url" do
        # We don't blank new_url if a redirect is changed to an archive. It would
        # be confusing to return archive mappings when filtering by new_url.

        create :archived, new_url: "http://f.gov.uk/1", site: site

        get :index, params: { site_id: site.abbr, new_url_contains: "f.gov.uk/1" }
        expect(assigns(:mappings)).to eq([mapping_a])
      end

      it "does not canonicalize the filter for new_url" do
        get :index, params: { site_id: site.abbr, new_url_contains: "/A/B/C/1?q=1" }
        expect(assigns(:filter).new_url_contains).to eq("/A/B/C/1?q=1")
      end

      it "extracts paths from full URLs supplied for filtering" do
        get :index, params: { site_id: site.abbr, path_contains: "https://www.example.com/foobar" }
        expect(assigns(:filter).path_contains).to eql("/foobar")
      end

      it "gracefully degrades if the filtering value looks like a URL but is unparseable" do
        get :index, params: { site_id: site.abbr, path_contains: "https://}" }
        expect(assigns(:filter).path_contains).to eql("https://}")
      end
    end

    describe "requesting a csv" do
      context "as a non-admin user" do
        before do
          login_as(gds_bob)
        end

        it "prevents you from accessing it" do
          get :index, params: { site_id: site.abbr, format: "csv" }
          expect(response).to redirect_to site_mappings_path(site)
          expect(flash[:notice]).to eql("Only admin users can access the CSV export")
        end
      end

      context "as an admin user" do
        before do
          login_as(admin_user)
        end

        describe "with one mapping" do
          let!(:mappings) { create(:redirect, path: "/a", new_url: "http://f.gov.uk/1", site: site) }

          it "produces a CSV" do
            get :index, params: { site_id: site.abbr, format: "csv" }
            expect(response.headers["Content-Type"]).to eql("text/csv")
            csv = CSV.parse(response.body)
            expect(csv.first).to eql(["Old URL", "Type", "New URL", "Archive URL", "Suggested URL"])
            expect(csv.size).to eql(2)
            expect(csv[1]).to eql(["http://moj.gov.uk/a", "redirect", "http://f.gov.uk/1", nil, nil])
          end
        end

        describe "with more mappings than appear on one page" do
          let!(:mappings) { 101.times { create(:mapping, site: site) } }

          it "includes all mappings, not just the current page" do
            get :index, params: { site_id: site.abbr, format: "csv" }
            csv = CSV.parse(response.body)
            expect(csv.size).to eql(102) # header + 101 rows
          end
        end
      end
    end
  end

  describe "#find_global" do
    before do
      login_as_stub_user
    end

    context "when the URL isn't supplied" do
      it "returns a 400 error" do
        get :find_global, params: { url: nil }
        expect(response.status).to eq(400)
      end
    end

    context "when the URL isn't a URL" do
      it "returns a 400 error" do
        get :find_global, params: { url: "http://this{looks_bad.com/bang" }
        expect(response.status).to eq(400)
      end
    end

    context "when the URL has a querystring" do
      let!(:host) { create :host, hostname: "example.com" }
      it "should preserve the querystring" do
        get :find_global, params: { url: "http://example.com/baz?q=a" }
        expect(response).to redirect_to site_mapping_find_url(host.site, path: "/baz?q=a")
      end
    end

    context "when the URL isn't an HTTP(S) URL" do
      let!(:host) { create :host, hostname: "example.com" }
      it "prefixes http:// to the beginning of the string and checks if it is a site" do
        get :find_global, params: { url: "example.com/hello" }
        expect(response).to redirect_to site_mapping_find_url(host.site, path: "/hello")
      end
    end

    context "when the URL is an HTTP(S) URL" do
      context "when the www. site exists for a domain" do
        let!(:host) { create :host, hostname: "www.attorneygeneral.gov.uk" }
        it "redirects to #find with the correct params" do
          get :find_global, params: { url: "http://aka.attorneygeneral.gov.uk/foo/bar" }
          expect(response).to redirect_to site_mapping_find_url(host.site, path: "/foo/bar")
        end
      end

      context "when the www. site doesn't exist for a domain" do
        it "returns a 404 error" do
          get :find_global, params: { url: "http://doesnotexist.gov.uk/no" }
          expect(response.status).to eq(404)
        end
      end

      context "when the URL starts or ends with whitespace" do
        let!(:host) { create :host, hostname: "example.com" }
        it "strips both leading and trailing whitespace" do
          get :find_global, params: { url: " http://example.com/hello " }
          expect(response).to redirect_to site_mapping_find_url(host.site, path: "/hello")
        end
      end
    end
  end

  describe "#find" do
    let(:raw_path)           { "/ABOUT/" }
    let(:canonicalized_path) { "/about" }

    before do
      login_as_stub_user
    end

    context "when no mapping exists yet for the canonicalized path" do
      it "redirects to the new mappings form" do
        get :find, params: { site_id: site.abbr, path: raw_path }

        expect(response).to redirect_to new_site_bulk_add_batch_path(site, paths: canonicalized_path)
      end
    end

    context "when a mapping exists for the canonicalized path" do
      it "redirects to the edit mapping form" do
        mapping = create(:mapping, site: site, path: canonicalized_path)

        get :find, params: { site_id: site.abbr, path: raw_path }

        expect(response).to redirect_to edit_site_mapping_path(site, mapping)
      end
    end

    context "when the path canonicalizes to a homepage" do
      invalid_path = "//"

      context "when there is a previous page to go back to" do
        it "redirects back to the previous page" do
          request.env["HTTP_REFERER"] = site_hits_url(site)

          get :find, params: { site_id: site.abbr, path: invalid_path }

          expect(response).to redirect_to site_hits_url(site)
        end

        context "when the previous page is on a different host" do
          it "should redirect to the mappings index" do
            request.env["HTTP_REFERER"] = "http://www.environment-agency.gov.uk.side-by-side"

            get :find, params: { site_id: site.abbr, path: invalid_path }

            expect(response).to redirect_to site_mappings_url(site)
          end
        end
      end

      context "when no previous page is available" do
        it "redirects to site mappings index" do
          get :find, params: { site_id: site.abbr, path: invalid_path }

          expect(response).to redirect_to site_mappings_url(site)
        end
      end
    end
  end

  describe "#edit" do
    context "without permission to edit" do
      def make_request
        get :edit, params: { site_id: mapping.site.abbr, id: mapping.id }
      end

      it_behaves_like "disallows editing by unaffiliated user"
    end
  end

  describe "#update" do
    context "without permission to edit" do
      def make_request
        put :update, params: { site_id: mapping.site.abbr, id: mapping.id }
      end

      it_behaves_like "disallows editing by unaffiliated user"
    end

    context "when Bob has permission to update a mapping, but is acting Evilly" do
      describe "updating with versioning", versioning: true do
        before do
          login_as gds_bob
          post :update,
               params: {
                 site_id: mapping.site,
                 id: mapping.id,
                 mapping: {
                   path: "/Needs/Canonicalization?has=some&query=parts",
                   new_url: "http://a.gov.uk",
                 },
               }
        end

        it "canonicalizes the path" do
          expect(mapping.reload.path).to eq("/needs/canonicalization")
        end

        describe "the recorded user" do
          subject { Mapping.first.versions.last }

          describe "#whodunnit" do
            subject { super().whodunnit }
            it { is_expected.to eql("Bob Terwhilliger") }
          end

          describe "#user_id" do
            subject { super().user_id }
            it { is_expected.to eql(gds_bob.id) }
          end
        end
      end
    end

    context "when an admin is trying to tag a mapping" do
      before do
        login_as gds_bob
        post :update,
             params: {
               site_id: mapping.site,
               id: mapping.id,
               mapping: {
                 path: "/Needs/Canonicalization?has=some&query=parts",
                 new_url: "http://somewhere.gov.uk",
                 tag_list: "fEE, fI, fO",
               },
             }
      end

      subject(:tags_as_strings) { mapping.reload.tags.map(&:to_s) }

      it "has saved all tags as lowercase" do
        expect(tags_as_strings).to match_array(%w[fee fi fo])
      end
    end
  end

  describe "#edit_multiple" do
    let!(:mapping_a) { create :mapping, path: "/a", site: site }
    let!(:mapping_b) { create :mapping, path: "/b", site: site }
    let!(:mapping_c) { create :mapping, path: "/c", site: site }

    before do
      @mappings_index_with_filter = site_mappings_path(site) + "?contains=%2Fa"
    end

    context "without permission to edit" do
      def make_request
        mapping_ids = [mapping_a.id, mapping_b.id]
        post :edit_multiple,
             params: {
               site_id: site.abbr,
               mapping_ids: mapping_ids,
               type: "archive",
               return_path: @mappings_index_with_filter,
             }
      end

      it_behaves_like "disallows editing by unaffiliated user"
    end

    context "when no mapping ids which exist on this site are posted" do
      let!(:other_site)    { create :site }
      let!(:other_mapping) { create :mapping, path: "/z", site: other_site }
      before do
        login_as gds_bob
      end

      context "when the mappings index has not been visited" do
        it "redirects to the mappings index page" do
          post :edit_multiple,
               params: {
                 site_id: site.abbr,
                 mapping_ids: [other_mapping.id],
                 type: "archive",
               }

          expect(response).to redirect_to site_mappings_path(site)
        end
      end

      context "when coming from the mappings index with a path filter" do
        it "redirects back to the last-visited mappings index page" do
          post :edit_multiple,
               params: {
                 site_id: site.abbr,
                 mapping_ids: [other_mapping.id],
                 type: "archive",
                 return_path: @mappings_index_with_filter,
               }

          expect(response).to redirect_to @mappings_index_with_filter
        end
      end
    end

    context "when an invalid new status is posted" do
      before do
        login_as gds_bob
      end

      context "when coming from the mappings index with a path filter" do
        it "redirects back to the last-visited mappings index page" do
          mapping_ids = [mapping_a.id, mapping_b.id]
          post :edit_multiple,
               params: {
                 site_id: site.abbr,
                 mapping_ids: mapping_ids,
                 type: "bad",
                 return_path: @mappings_index_with_filter,
               }

          expect(response).to redirect_to @mappings_index_with_filter
        end
      end
    end

    context "when requesting tagging for selected existing mappings with no JS" do
      let(:mapping_ids) { [mapping_a.id, mapping_b.id] }

      before do
        login_as gds_bob
        post :edit_multiple,
             params: {
               site_id: site.abbr,
               mapping_ids: mapping_ids,
               operation: "tag",
               return_path: "should_not_return",
             }
      end

      it "shows the tagging page" do
        expect(response).to have_rendered "mappings/edit_multiple"
      end
    end
  end

  describe "#update_multiple" do
    let!(:mapping_a) { create :mapping, path: "/a", site: site, tag_list: "fum", as_user: gds_bob }
    let!(:mapping_b) { create :mapping, path: "/b", site: site, tag_list: "fum", as_user: gds_bob }
    let!(:mapping_c) { create :mapping, path: "/c", site: site, tag_list: "fum", as_user: gds_bob }

    before do
      @mappings_index_with_filter = site_mappings_path(site) + "?contains=%2Fa"
    end

    context "without permission to edit" do
      def make_request
        mapping_ids = [mapping_a.id, mapping_b.id]
        post :update_multiple,
             params: {
               site_id: site.abbr,
               mapping_ids: mapping_ids,
               operation: "redirect",
               new_url: "http://a.gov.uk",
             }
      end

      it_behaves_like "disallows editing by unaffiliated user"

      it "does not update any mappings" do
        login_as stub_user
        make_request

        expect(site.mappings.where(type: "redirect").count).to be(0)
      end
    end

    context "when valid data is posted", versioning: true do
      before do
        login_as gds_bob
        mapping_ids = [mapping_a.id, mapping_b.id]
        @new_url = "http://a.gov.uk"
        post :update_multiple,
             params: {
               site_id: site.abbr,
               mapping_ids: mapping_ids,
               operation: "redirect",
               new_url: @new_url,
               return_path: @mappings_index_with_filter,
             }
      end

      it "updates the mappings correctly" do
        [mapping_a, mapping_b].each do |mapping|
          mapping.reload
          expect(mapping.type).to eql("redirect")
          expect(mapping.new_url).to eql("http://a.gov.uk")
        end
      end

      it "does not update other mappings" do
        mapping_c.reload
        expect(mapping_c.type).to eql("archive")
        expect(mapping_c.new_url).to be_nil
      end

      it "redirects to the last-visited mappings index page" do
        expect(response).to redirect_to @mappings_index_with_filter
      end

      it "saves a version for each mapping recording the change" do
        [mapping_a, mapping_b].each do |mapping|
          mapping.reload
          expect(mapping.versions.count).to eql(2)
          expect(mapping.versions.last.whodunnit).to eql("Bob Terwhilliger")
        end
      end
    end

    context "when no mapping ids which exist on this site are posted" do
      let!(:other_site)    { create :site }
      let!(:other_mapping) { create :mapping, path: "/z", site: other_site }
      before do
        login_as gds_bob
      end

      context "when the mappings index has not been visited" do
        it "redirects to the mappings index page" do
          post :update_multiple,
               params: {
                 site_id: site.abbr,
                 mapping_ids: [other_mapping.id],
                 type: "redirect",
                 new_url: "http://a.gov.uk",
               }

          expect(response).to redirect_to site_mappings_path(site)
        end
      end

      context "when the mappings index was last visited with a path filter" do
        it "redirects back to the last-visited mappings index page" do
          post :update_multiple,
               params: {
                 site_id: site.abbr,
                 mapping_ids: [other_mapping.id],
                 type: "redirect",
                 new_url: "http://a.gov.uk",
                 return_path: @mappings_index_with_filter,
               }

          expect(response).to redirect_to @mappings_index_with_filter
        end
      end
    end

    context "when the posted new_url is not a valid URL" do
      before do
        login_as gds_bob
        mapping_ids = [mapping_a.id, mapping_b.id]
        post :update_multiple,
             params: {
               site_id: site.abbr,
               mapping_ids: mapping_ids,
               type: "redirect",
               new_url: "http://{",
             }
      end

      it "does not update any mappings" do
        expect(site.mappings.where(type: "redirect").count).to be(0)
      end
    end
  end

  describe "displaying background bulk add status" do
    context "outcome hasn't been seen yet" do
      let!(:mappings_batch) { create(:bulk_add_batch, site: site, user: gds_bob, state: "succeeded") }
      before do
        login_as(gds_bob)
        get :index, params: { site_id: site }
      end

      it "should set the progress message" do
        expect(flash.now[:batch_progress]).to eql(message: "0 of 2 mappings added", type: :success)
      end

      it "should prevent caching of the page" do
        expect(response.headers["Cache-Control"]).to eq("no-cache, no-store")
        expect(response.headers["Pragma"]).to eq("no-cache")
        expect(response.headers["Expires"]).to eq("Fri, 01 Jan 1990 00:00:00 GMT")
      end

      it "should record that the outcome of processing the batch has been seen" do
        mappings_batch.reload
        expect(mappings_batch.seen_outcome).to eq(true)
      end
    end

    context "outcome has been seen" do
      let!(:mappings_batch) { create(:bulk_add_batch, site: site, user: gds_bob, state: "succeeded", seen_outcome: true) }
      before do
        login_as(gds_bob)
        get :index, params: { site_id: site }
      end

      it "should not show an outcome message" do
        expect(flash.now[:batch_progress]).to be_nil
      end

      it "should not prevent caching of the page" do
        expect(response.headers["Cache-Control"]).to be_nil
        expect(response.headers["Pragma"]).to be_nil
        expect(response.headers["Expires"]).to be_nil
      end
    end

    context "the batch is for another site" do
      let!(:mappings_batch) { create(:bulk_add_batch, site: create(:site), user: gds_bob, state: "succeeded") }
      before do
        login_as(gds_bob)
        get :index, params: { site_id: site }
      end

      it "should not show" do
        expect(flash.now[:batch_progress]).to be_nil
      end
    end
  end

  describe "rejecting an invalid or missing authenticity (CSRF) token" do
    before do
      login_as gds_bob
    end

    it "should return a 403 response" do
      # as allow_forgery_protection is disabled in the test environment, we're
      # stubbing the verified_request? method from
      # ActionController::RequestForgeryProtection::ClassMethods to return false
      # in order to test our override of the verify_authenticity_token method
      allow(subject).to receive(:verified_request?).and_return(false)
      post :update,
           params: {
             site_id: mapping.site,
             id: mapping.id,
             mapping: { path: "/foo" },
           }

      expect(response.status).to eql(403)
    end
  end

  describe "rejecting an off-site return_path" do
    before do
      login_as gds_bob
    end

    context "update" do
      it "should redirect to mappings index" do
        post :update,
             params: {
               site_id: mapping.site,
               id: mapping.id,
               mapping: {
                 path: "/Needs/Canonicalization?has=some&query=parts",
                 new_url: "http://a.gov.uk",
               },
               return_path: "http://malicious.com",
             }

        expect(response).to redirect_to site_mappings_path(site)
      end
    end

    context "#update_multiple" do
      let(:mapping) { create :mapping, path: "/a", site: site }

      it "should redirect to mappings index" do
        post :update_multiple,
             params: {
               site_id: site.abbr,
               mapping_ids: [mapping.id],
               operation: "redirect",
               new_url: "http://a.gov.uk",
               return_path: "http://malicious.com",
             }

        expect(response).to redirect_to site_mappings_path(site)
      end
    end
  end

  describe "mappings for sites with global http statuses" do
    before do
      login_as stub_user
      get :index, params: { site_id: site.abbr }
    end

    shared_examples "it disallows the editing of mappings" do
      it "redirects to the site dashboard" do
        expect(response).to redirect_to site_path(site.abbr)
      end

      it "sets a flash message" do
        expect(flash[:alert]).to include(expected_alert)
      end
    end

    context "when a site has a global redirect" do
      let(:site)           { create :site, abbr: "bis", global_type: "redirect", global_new_url: "http://a.co" }
      let(:expected_alert) { "entirely redirected" }

      it_behaves_like "it disallows the editing of mappings"
    end

    context "when a site has a global archive" do
      let(:site)           { create :site, abbr: "bis", global_type: "archive" }
      let(:expected_alert) { "entirely archived" }

      it_behaves_like "it disallows the editing of mappings"
    end
  end
end
