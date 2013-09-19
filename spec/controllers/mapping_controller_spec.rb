require 'spec_helper'

describe MappingsController, versioning: true do
  describe '#update for paper_trail' do
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
