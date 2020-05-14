require "rails_helper"

describe BulkAddBatchesController do
  let(:site) { create :site, abbr: "moj" }
  let(:global_site) { create :site, global_type: "archive" }
  let(:batch) { create(:bulk_add_batch, site: site) }
  let(:gds_bob) { create(:gds_editor, name: "Bob Terwhilliger") }
  let(:mapping) { create(:mapping, site: site, as_user: gds_bob) }

  describe "#new" do
    context "without permission to edit" do
      def make_request
        get :new, params: { site_id: site.abbr }
      end

      it_behaves_like "disallows editing by unaffiliated user"
    end

    context "when the user does have permission" do
      before do
        login_as gds_bob
      end

      it "displays the form" do
        get :new, params: { site_id: site.abbr }
        expect(response.status).to eql(200)
      end

      context "but the site is global" do
        def make_request
          post :create, params: { site_id: global_site.abbr }
        end

        it_behaves_like "disallows editing of a global site"
      end
    end
  end

  describe "#create" do
    context "without permission to edit" do
      def make_request
        post :create, params: { site_id: site.abbr }
      end

      it_behaves_like "disallows editing by unaffiliated user"
    end

    context "for a global site" do
      before do
        login_as gds_bob
      end

      def make_request
        post :create, params: { site_id: global_site.abbr }
      end

      it_behaves_like "disallows editing of a global site"
    end
  end

  describe "#preview" do
    before do
      login_as gds_bob
    end

    context "when the return path is on site" do
      it "returns to where it came from" do
        get :preview,
            params: {
              site_id: site.abbr,
              id: batch.id,
              return_path: "/donkey",
            }

        expect(assigns(:bulk_add_cancel_destination)).to eq("/donkey")
      end
    end

    context "when the return path is off site" do
      it "returns to the site mappings path" do
        get :preview,
            params: {
              site_id: site.abbr,
              id: batch.id,
              return_path: "http://google.com",
            }

        expect(assigns(:bulk_add_cancel_destination)).to eq(site_mappings_path(site.abbr))
      end
    end

    context "for a global site" do
      def make_request
        post :create, params: { site_id: global_site.abbr }
      end

      it_behaves_like "disallows editing of a global site"
    end
  end

  describe "#import" do
    context "without permission to edit" do
      def make_request
        post :import, params: { site_id: site.abbr, id: batch.id }
      end

      it_behaves_like "disallows editing by unaffiliated user"
    end

    context "when user can edit the site" do
      before do
        login_as gds_bob
      end

      context "but it is global" do
        def make_request
          post :create, params: { site_id: global_site.abbr }
        end

        it_behaves_like "disallows editing of a global site"
      end

      context "a small batch" do
        def make_request
          post :import,
               params: {
                 site_id: site.abbr,
                 update_existing: "true",
                 id: batch.id,
               }
        end

        include_examples "it processes a small batch inline"
      end

      context "a large batch" do
        let(:large_batch) do
          create(
            :bulk_add_batch,
            site: site,
            paths: %w[/1 /2 /3 /4 /5 /6 /7 /8 /9 /10 /11 /12 /13 /14 /15 /16 /17 /18 /19 /20 /21],
          )
        end

        def make_request
          post :import,
               params: {
                 site_id: site.abbr,
                 update_existing: "true",
                 id: large_batch.id,
               }
        end

        include_examples "it processes a large batch in the background"
      end

      context "a batch which has been submitted already" do
        def make_request
          post :import, params: { site_id: site.abbr, id: batch.id }
        end

        include_examples "it doesn't requeue a batch which has already been queued"
      end

      context "a redirect batch containing long new_urls" do
        let!(:whitelisted_host) { create :whitelisted_host, hostname: "example.com" }
        let(:stem)              { "http://#{whitelisted_host.hostname}/" }
        let(:long_url)          { "#{stem}#{'x' * (2048 - stem.length)}" }
        let(:batch) do
          create(
            :bulk_add_batch,
            site: site,
            type: "redirect",
            new_url: long_url,
          )
        end

        before do
          post :import, params: { site_id: site.abbr, id: batch.id }
        end

        it "creates each mapping in the batch" do
          expect(site.mappings.size).to eq(2)
        end

        it "has the long url for each" do
          Mapping.all.each do |mapping|
            expect(mapping.new_url).to eql(long_url)
          end
        end
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
      post :import, params: { site_id: mapping.site, id: batch.id }
      expect(response.status).to eql(403)
    end
  end

  describe "rejecting an off-site return_path" do
    before do
      login_as gds_bob
    end

    context "#import" do
      it "should redirect to mappings index" do
        post :import,
             params: {
               site_id: site.abbr,
               id: batch.id,
               return_path: "http://malicious.com",
             }
        expect(response).to redirect_to site_mappings_path(site)
      end
    end
  end
end
