require 'spec_helper'

describe MappingsController do
  describe '#index' do
    let(:site)      { create :site, abbr: 'moj' }
    let(:mapping_a) { create :mapping, path: '/a', site: site }
    let(:mapping_b) { create :mapping, path: '/b', site: site }
    let(:mapping_c) { create :mapping, path: '/c', site: site}

    before do
      login_as_stub_user
      [mapping_c, mapping_b, mapping_a].each {|mapping| mapping.should be_persisted}

      get :index, site_id: site.abbr
    end

    it 'orders mappings by path' do
      assigns(:mappings).should == [mapping_a, mapping_b, mapping_c]
    end
  end

  describe '#update for paper_trail', versioning: true do
    let(:user)    { FactoryGirl.create(:admin, name: 'Bob Terwhilliger') }
    let(:mapping) { create :mapping }

    before do
      login_as user

      post :update, site_id: mapping.site, id: mapping.id, mapping: { new_url: 'http://somewhere.bad' }
    end

    describe 'the recorded user' do
      subject { Mapping.first.versions.last }

      its(:whodunnit) { should eql('Bob Terwhilliger') }
      its(:user_id)   { should eql(user.id) }
    end
  end

  describe '#find' do
    let(:site) { FactoryGirl.create(:site) }
    raw_path = '/ABOUT/'
    canonicalized_path = '/about'

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
        mapping = FactoryGirl.create(:mapping, site: site, path: canonicalized_path)

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
    context 'user doesn\'t have permission' do
      let(:site) { FactoryGirl.create(:site) }

      before do
        user = FactoryGirl.create(:user, organisation_slug: nil)
        login_as user
      end

      it 'redirects to the index page and sets a flash message' do
        get :new, site_id: site.abbr
        expect(response).to redirect_to site_mappings_path(site)
      end
    end
  end
end
