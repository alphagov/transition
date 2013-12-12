require 'spec_helper'

describe MappingsController do
  let(:site)              { create :site, abbr: 'moj' }
  let(:unaffiliated_user) { create(:user, organisation_slug: nil) }
  let(:admin_bob)         { create(:admin, name: 'Bob Terwhilliger') }
  let(:mapping)           { create(:mapping) }

  describe '#index' do
    let(:mapping_a) { create :mapping, path: '/a', site: site }
    let(:mapping_b) { create :mapping, path: '/b', site: site }
    let(:mapping_c) { create :mapping, path: '/c', site: site }

    before do
      login_as_stub_user
      [mapping_c, mapping_b, mapping_a].each {|mapping| mapping.should be_persisted}

      get :index, site_id: site.abbr
    end

    it 'orders mappings by path' do
      assigns(:mappings).should == [mapping_a, mapping_b, mapping_c]
    end
  end

  describe '#find' do
    let(:raw_path)           { '/ABOUT/' }
    let(:canonicalized_path) { '/about' }

    before do
      login_as_stub_user
    end

    context 'when no mapping exists yet for the canonicalized path' do
      it 'redirects to the new mapping form' do
        get :find, site_id: site.abbr, path: raw_path

        expect(response).to redirect_to new_site_mapping_path(site, path: canonicalized_path)
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
      end

      context 'when no previous page is available' do
        it 'redirects to site mappings index' do
          request.env['HTTP_REFERER'] = nil

          get :find, site_id: site.abbr, path: invalid_path

          expect(response).to redirect_to site_mappings_url(site)
        end
      end
    end
  end

  describe '#new' do
    context 'when user doesn\'t have permission' do
      before do
        login_as unaffiliated_user
        get :new, site_id: site.abbr
      end

      it 'redirects to the index page and sets a flash message' do
        expect(response).to redirect_to site_mappings_path(site)
      end
    end
  end

  describe '#create' do
    context 'when user doesn\'t have permission' do
      before do
        login_as unaffiliated_user
        post :create, site_id: site.abbr
      end

      it 'redirects to the index page and sets a flash message' do
        expect(response).to redirect_to site_mappings_path(site)
      end
    end
  end

  describe '#edit' do
    context 'when user doesn\'t have permission' do
      before do
        login_as unaffiliated_user
      end

      it 'redirects to the index page and sets a flash message' do
        get :edit, site_id: mapping.site.abbr, id: mapping.id
        expect(response).to redirect_to site_mappings_path(mapping.site)
      end
    end
  end

  describe '#update' do
    context 'when user doesn\'t have permission' do
      before do
        login_as unaffiliated_user
        put :update, site_id: mapping.site.abbr, id: mapping.id
      end

      it 'redirects to the index page' do
        expect(response).to redirect_to site_mappings_path(mapping.site)
      end
    end

    context 'when Bob has permission to update a mapping, but is acting Evilly' do
      describe 'updating with versioning', versioning: true do
        before do
          login_as admin_bob
          post :update, site_id: mapping.site, id: mapping.id,
               mapping: { path: '/Needs/Canonicalization?has=some&query=parts', new_url: 'http://somewhere.bad' }
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
  end

  describe '#edit_multiple' do
    let!(:mapping_a) { create :mapping, path: '/a', site: site }
    let!(:mapping_b) { create :mapping, path: '/b', site: site }
    let!(:mapping_c) { create :mapping, path: '/c', site: site }

    context 'when user doesn\'t have permission' do
      before do
        login_as unaffiliated_user
      end

      it 'redirects to the index page and sets a flash message' do
        mapping_ids = [ mapping_a.id, mapping_b.id ]
        post :edit_multiple, site_id: site.abbr, mapping_ids: mapping_ids, new_status: 'archive'
        expect(response).to redirect_to site_mappings_path(site)
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
      post :create, site_id: mapping.site,
               mapping: { path: '/foo', http_status: '410' }
      response.status.should eql(403)
      response.body.should eql('Invalid authenticity token')
    end
  end
end
