require 'spec_helper'

describe MappingsController do
  let(:site)              { create :site, abbr: 'moj' }
  let(:unaffiliated_user) { create(:user, organisation_slug: nil) }
  let(:admin_bob)         { create(:admin, name: 'Bob Terwhilliger') }
  let(:mapping)           { create(:mapping, site: site) }

  shared_examples 'disallows editing by unaffiliated user' do
    before do
      login_as unaffiliated_user
      make_request
    end

    it 'redirects to the index page' do
      expect(response).to redirect_to site_mappings_path(site)
    end

    it 'sets a flash message' do
      flash[:alert].should include('don\'t have permission to edit')
    end
  end

  describe '#index' do
    let!(:mapping_a) { create :redirect, path: '/a', new_url: 'http://f.co/1', site: site }
    let!(:mapping_b) { create :redirect, path: '/b', new_url: 'http://f.co/2', site: site }
    let!(:mapping_c) { create :redirect, path: '/c', new_url: 'http://f.co/3', site: site }

    before do
      login_as_stub_user
    end

    it 'orders mappings by path' do
      get :index, site_id: site.abbr
      assigns(:mappings).should == [mapping_a, mapping_b, mapping_c]
    end

    describe 'filtering' do
      it 'filters mappings by path' do
        get :index, site_id: site.abbr, path_contains: 'a'
        assigns(:mappings).should == [mapping_a]
      end

      it 'canonicalises filter input' do
        get :index, site_id: site.abbr, path_contains: '/A?q=1'
        assigns(:mappings).should == [mapping_a]
      end

      it 'filters mappings by new_url' do
        get :index, site_id: site.abbr, new_url_contains: 'f.co/1'
        assigns(:mappings).should == [mapping_a]
      end

      it 'ignores non-redirect mappings when filtering by new_url' do
        # We don't blank new_url if a redirect is changed to an archive. It would
        # be confusing to return archive mappings when filtering by new_url.

        create :archived, new_url: 'http://f.co/1', site: site

        get :index, site_id: site.abbr, new_url_contains: 'f.co/1'
        assigns(:mappings).should == [mapping_a]
      end

      it 'does not canonicalize the filter for new_url' do
        get :index, site_id: site.abbr, new_url_contains: '/A/B/C/1?q=1'
        assigns(:new_url_contains).should == '/A/B/C/1?q=1'
      end

      it 'extracts paths from full URLs supplied for filtering' do
        get :index, site_id: site.abbr, path_contains: 'https://www.example.com/foobar'
        assigns(:path_contains).should eql('/foobar')
      end

      it 'gracefully degrades if the filtering value looks like a URL but is unparseable' do
        get :index, site_id: site.abbr, path_contains: 'https://____'
        assigns(:path_contains).should eql('https://____')
      end
    end
  end


  describe '#find_global' do
    before do
      login_as_stub_user
    end

    context 'when the URL isn\'t supplied' do
      it 'returns a 400 error' do
        get :find_global, url: nil
        expect(response.status).to eq(400)
      end
    end

    context 'when the URL isn\'t a URL' do
      it 'returns a 400 error' do
        get :find_global, url: 'http://this_looks_bad.com/bang'
        expect(response.status).to eq(400)
      end
    end

    context 'when the URL isn\'t an HTTP(S) URL' do
      it 'returns a 400 error' do
        get :find_global, url: "huihguifbelgfebigf"
        expect(response.status).to eq(400)
      end
    end

    context 'when the URL is an HTTP(S) URL' do
      context 'when the www. site exists for a domain' do
        let!(:host) { create :host, hostname: "www.attorneygeneral.gov.uk" }
        it 'redirects to #find with the correct params' do
          get :find_global, url: "http://aka.attorneygeneral.gov.uk/foo/bar"
          expect(response).to redirect_to site_mapping_find_url(host.site, path: "/foo/bar")
        end
      end

      context 'when the www. site doesn\'t exist for a domain' do
        it 'returns a 404 error' do
          get :find_global, url: "http://doesnotexist.gov.uk/no"
          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe '#find' do
    let(:raw_path)           { '/ABOUT/' }
    let(:canonicalized_path) { '/about' }

    before do
      login_as_stub_user
    end

    context 'when no mapping exists yet for the canonicalized path' do
      it 'redirects to the new mappings form' do
        get :find, site_id: site.abbr, path: raw_path

        expect(response).to redirect_to new_multiple_site_mappings_path(site, paths: canonicalized_path)
      end
    end

    context 'when a mapping exists for the canonicalized path' do
      it 'redirects to the edit mapping form' do
        mapping = create(:mapping, site: site, path: canonicalized_path)

        get :find, site_id: site.abbr, path: raw_path

        expect(response).to redirect_to edit_site_mapping_path(site, mapping)
      end
    end

    context 'when the path canonicalizes to a homepage' do
      invalid_path = '//'

      context 'when there is a previous page to go back to' do
        it 'redirects back to the previous page' do
          request.env['HTTP_REFERER'] = site_hits_url(site)

          get :find, site_id: site.abbr, path: invalid_path

          expect(response).to redirect_to site_hits_url(site)
        end

        context 'when the previous page is on a different host' do
          it 'should redirect to the mappings index' do
            request.env['HTTP_REFERER'] = 'http://www.environment-agency.gov.uk.side-by-side'

            get :find, site_id: site.abbr, path: invalid_path

            expect(response).to redirect_to site_mappings_url(site)
          end
        end
      end

      context 'when no previous page is available' do
        it 'redirects to site mappings index' do
          get :find, site_id: site.abbr, path: invalid_path

          expect(response).to redirect_to site_mappings_url(site)
        end
      end
    end
  end

  describe '#edit' do
    context 'without permission to edit' do
      def make_request
        get :edit, site_id: mapping.site.abbr, id: mapping.id
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end
  end

  describe '#update' do
    context 'without permission to edit' do
      def make_request
        put :update, site_id: mapping.site.abbr, id: mapping.id
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'when Bob has permission to update a mapping, but is acting Evilly' do
      describe 'updating with versioning', versioning: true do
        before do
          login_as admin_bob
          post :update, site_id: mapping.site, id: mapping.id,
               mapping: {
                  path: '/Needs/Canonicalization?has=some&query=parts',
                  new_url: 'http://somewhere.bad'
               }
        end

        it 'canonicalises the path' do
          mapping.reload.path.should == '/needs/canonicalization'
        end

        describe 'the recorded user' do
          subject { Mapping.first.versions.last }

          its(:whodunnit) { should eql('Bob Terwhilliger') }
          its(:user_id)   { should eql(admin_bob.id) }
        end
      end
    end

    context 'when an admin is trying to tag a mapping' do
      before do
        login_as admin_bob
        post :update, site_id: mapping.site, id: mapping.id,
             mapping: {
                path: '/Needs/Canonicalization?has=some&query=parts',
                new_url: 'http://somewhere.good',
                tag_list: 'fEE, fI, fO'
             }
      end

      subject(:tags_as_strings) { mapping.reload.tags.map(&:to_s) }

      it 'has saved all tags as lowercase' do
        tags_as_strings.should == ['fee', 'fi', 'fo']
      end
    end
  end

  describe '#new_multiple' do
    context 'without permission to edit' do
      def make_request
        get :new_multiple, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'when the user does have permission' do
      before do
        login_as admin_bob
      end

      it 'displays the form' do
        get :new_multiple, site_id: site.abbr
        expect(response.status).to eql(200)
      end
    end
  end

  describe '#new_multiple_confirmation' do
    context 'without permission to edit' do
      def make_request
        post :new_multiple_confirmation, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'when no new_url is posted for redirects' do
      before do
        login_as admin_bob
        post :new_multiple_confirmation, site_id: site.abbr, paths: "/a\n/b",
             http_status: '301', new_url: ''
      end

      it 'renders the form again' do
        expect(response).to render_template 'mappings/new_multiple'
      end

      it 'sets an error for new_url' do
        expected_errors = { 'new_url' => I18n.t('mappings.bulk.new_url_invalid') }
        expect(assigns(:errors)).to eq(expected_errors)
      end
    end

    context 'when adding tags to multiple paths' do
      before do
        login_as admin_bob
        post :new_multiple_confirmation, site_id: site.abbr, paths: "/a\n/b",
             http_status: '301', new_url: 'http://gov.uk/somewhere',
             tag_list: 'fee, fi, FO'
      end

      let(:bulk_adder) { assigns(:bulk_add) }

      it 'has assigned the tag list to the bulk adder' do
        bulk_adder.tag_list.map(&:to_s).should == %w(fee fi fo)
      end
    end
  end

  describe '#create_multiple' do
    context 'without permission to edit' do
      def make_request
        post :create_multiple, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'when user can edit the site' do
      before do
        login_as admin_bob
      end

      context 'when no new_url is posted for redirects' do
        it 'renders the form with errors' do
          post :create_multiple, site_id: site.abbr, paths: "/a\n/b",
               http_status: '301', new_url: '', update_existing: 'true'
          expect(response).to render_template 'mappings/new_multiple'
        end
      end

      context 'with valid data' do
        before do
          post :create_multiple, site_id: site.abbr, paths: "/a\n/b",
               http_status: '301', new_url: 'www.gov.uk', update_existing: 'true'
        end

        it 'redirects to the site return URL' do
          expect(response).to redirect_to site_mappings_path(site)
        end

        it 'sets a success message' do
          flash[:success].should include('mappings created')
        end

        it 'creates new mappings' do
          expect(site.mappings.count).to eql(2)
        end
      end
    end
  end

  describe '#edit_multiple' do
    let!(:mapping_a) { create :mapping, path: '/a', site: site }
    let!(:mapping_b) { create :mapping, path: '/b', site: site }
    let!(:mapping_c) { create :mapping, path: '/c', site: site }

    before do
      @mappings_index_with_filter = site_mappings_path(site) + '?contains=%2Fa'
    end

    context 'without permission to edit' do
      def make_request
        mapping_ids = [ mapping_a.id, mapping_b.id ]
        post :edit_multiple, site_id: site.abbr, mapping_ids: mapping_ids,
             http_status: '410', return_path: @mappings_index_with_filter
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'when no mapping ids which exist on this site are posted' do
      let!(:other_site)    { create :site }
      let!(:other_mapping) { create :mapping, path: '/z', site: other_site }
      before do
        login_as admin_bob
      end

      context 'when the mappings index has not been visited' do
        it 'redirects to the mappings index page' do
          post :edit_multiple, site_id: site.abbr,
               mapping_ids: [other_mapping.id], http_status: '410'
          expect(response).to redirect_to site_mappings_path(site)
        end
      end

      context 'when coming from the mappings index with a path filter' do
        it 'redirects back to the last-visited mappings index page' do
          post :edit_multiple, site_id: site.abbr,
               mapping_ids: [other_mapping.id], http_status: '410',
               return_path: @mappings_index_with_filter
          expect(response).to redirect_to @mappings_index_with_filter
        end
      end
    end

    context 'when an invalid new status is posted' do
      before do
        login_as admin_bob
      end

      context 'when coming from the mappings index with a path filter' do
        it 'redirects back to the last-visited mappings index page' do
          mapping_ids = [ mapping_a.id, mapping_b.id ]
          post :edit_multiple, site_id: site.abbr, mapping_ids: mapping_ids,
               http_status: 'bad', return_path: @mappings_index_with_filter
          expect(response).to redirect_to @mappings_index_with_filter
        end
      end
    end

    context 'when requesting tagging for selected existing mappings with no JS' do
      let(:mapping_ids) { [mapping_a.id, mapping_b.id] }

      before do
        login_as admin_bob
        post :edit_multiple, site_id: site.abbr, mapping_ids: mapping_ids,
             operation: 'tag', return_path: 'should_not_return'
      end

      it 'shows the tagging page' do
        expect(response).to have_rendered 'mappings/edit_multiple'
      end
    end
  end

  describe '#update_multiple' do
    let!(:mapping_a) { create :mapping, path: '/a', site: site, tag_list: 'fum' }
    let!(:mapping_b) { create :mapping, path: '/b', site: site, tag_list: 'fum' }
    let!(:mapping_c) { create :mapping, path: '/c', site: site, tag_list: 'fum' }

    before do
      @mappings_index_with_filter = site_mappings_path(site) + '?contains=%2Fa'
    end

    context 'without permission to edit' do
      def make_request
        mapping_ids = [ mapping_a.id, mapping_b.id ]
        post :update_multiple, site_id: site.abbr, mapping_ids: mapping_ids,
             operation: '301', new_url: 'http://www.example.com'
      end

      it_behaves_like 'disallows editing by unaffiliated user'

      it 'does not update any mappings' do
        login_as unaffiliated_user
        make_request

        expect(site.mappings.where(http_status: '301').count).to be(0)
      end
    end

    context 'when valid data is posted', versioning: true do
      before do
        login_as admin_bob
        mapping_ids = [ mapping_a.id, mapping_b.id ]
        @new_url = 'http://www.example.com'
        post :update_multiple, site_id: site.abbr, mapping_ids: mapping_ids,
             operation: '301', new_url: @new_url,
             return_path: @mappings_index_with_filter
      end

      it 'updates the mappings correctly' do
        [mapping_a, mapping_b].each do |mapping|
          mapping.reload
          expect(mapping.http_status).to eql('301')
          expect(mapping.new_url).to eql('http://www.example.com')
        end
      end

      it 'does not update other mappings' do
        mapping_c.reload
        expect(mapping_c.http_status).to eql('410')
        expect(mapping_c.new_url).to be_nil
      end

      it 'redirects to the last-visited mappings index page' do
        expect(response).to redirect_to @mappings_index_with_filter
      end

      it 'saves a version for each mapping recording the change' do
        [mapping_a, mapping_b].each do |mapping|
          mapping.reload
          expect(mapping.versions.count).to be(2)
          expect(mapping.versions.last.whodunnit).to eql('Bob Terwhilliger')
        end
      end
    end

    context 'when no mapping ids which exist on this site are posted' do
      let!(:other_site)    { create :site }
      let!(:other_mapping) { create :mapping, path: '/z', site: other_site }
      before do
        login_as admin_bob
      end

      context 'when the mappings index has not been visited' do
        it 'redirects to the mappings index page' do
          post :update_multiple, site_id: site.abbr,
               mapping_ids: [other_mapping.id], http_status: '301',
               new_url: 'http://www.example.com'
          expect(response).to redirect_to site_mappings_path(site)
        end
      end

      context 'when the mappings index was last visited with a path filter' do
        it 'redirects back to the last-visited mappings index page' do
          post :update_multiple, site_id: site.abbr,
               mapping_ids: [other_mapping.id], http_status: '301',
               new_url: 'http://www.example.com',
               return_path: @mappings_index_with_filter
          expect(response).to redirect_to @mappings_index_with_filter
        end
      end
    end

    context 'when the posted new_url is not a valid URL' do
      before do
        login_as admin_bob
        mapping_ids = [ mapping_a.id, mapping_b.id ]
        post :update_multiple, site_id: site.abbr, mapping_ids: mapping_ids,
             http_status: '301', new_url: '___'
      end

      it 'does not update any mappings' do
        expect(site.mappings.where(http_status: '301').count).to be(0)
      end
    end
  end

  describe 'rejecting an invalid or missing authenticity (CSRF) token' do
    before do
      login_as admin_bob
    end

    it 'should return a 403 response' do
      # as allow_forgery_protection is disabled in the test environment, we're
      # stubbing the verified_request? method from
      # ActionController::RequestForgeryProtection::ClassMethods to return false
      # in order to test our override of the verify_authenticity_token method
      subject.stub(:verified_request?).and_return(false)
      post :create_multiple, site_id: mapping.site,
           mapping: { paths: ['/foo'], http_status: '410', update_existing: 'false' }
      response.status.should eql(403)
      response.body.should eql('Invalid authenticity token')
    end
  end

  describe 'rejecting an off-site return_path' do
    before do
      login_as admin_bob
    end

    context 'update' do
      it 'should redirect to mappings index' do
        post :update, site_id: mapping.site, id: mapping.id,
               mapping: {
                  path: '/Needs/Canonicalization?has=some&query=parts',
                  new_url: 'http://somewhere.bad'
               },
               return_path: 'http://malicious.com'


        expect(response).to redirect_to site_mappings_path(site)
      end
    end

    context '#update_multiple' do
      let(:mapping) { create :mapping, path: '/a', site: site }

      it 'should redirect to mappings index' do
        post :update_multiple, site_id: site.abbr, mapping_ids: [mapping.id],
             operation: '301', new_url: 'http://www.example.com',
             return_path: 'http://malicious.com'

        expect(response).to redirect_to site_mappings_path(site)
      end
    end

    context '#create_multiple' do
      it 'should redirect to mappings index' do
        post :create_multiple, site_id: site.abbr, paths: "/a\n/b",
               http_status: '301', new_url: 'www.gov.uk', update_existing: 'true',
               return_path: 'http://malicious.com'
        expect(response).to redirect_to site_mappings_path(site)
      end
    end
  end
end
