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
    let(:user)    { FactoryGirl.create(:user, name: 'Bob Terwhilliger') }
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
end
