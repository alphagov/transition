require 'spec_helper'

describe OrganisationsController do
  before do
    login_as_stub_user
  end

  describe '#index' do
    let!(:test_organisations) { [create(:organisation), create(:organisation)] }

    before do
      get :index
    end

    it 'is ok' do
      response.status.should == 200
    end

    it 'has a list of organisations' do
      assigns(:organisations).should eql(test_organisations)
    end
  end

  describe '#show' do
    let!(:organisation) { create :organisation, abbr: 'funk' }

    before do
      get :show, id: 'funk'
    end

    it 'assigns the organisation' do
      assigns(:organisation).should == organisation
    end
  end
end
