require 'spec_helper'

describe OrganisationsController do
  describe '#index' do

    let(:organisation_z) { create :organisation, title: 'Zzzzzz' }
    let(:organisation_a) { create :organisation, title: 'Aaaaaa' }

    before do
      organisation_z.should be_persisted
      organisation_a.should be_persisted

      login_as_stub_user
      get :index
    end

    it 'orders organisations alphabetically' do
      assigns(:organisations).should == [organisation_a, organisation_z]
    end
  end
end
