require 'spec_helper'

describe User do
  describe 'organisation' do
    context 'user has no organisation slug set' do
      subject(:user) { FactoryGirl.create(:user, organisation_slug: nil) }

      its(:organisation) { should eql(nil) }
    end

    context 'user has an organisation slug set' do
      subject(:user) { FactoryGirl.create(:user, organisation_slug: "ministry-of-funk") }
      let(:ministry_of_funk) { FactoryGirl.create(:organisation, whitehall_slug: "ministry-of-funk")}

      its(:organisation) { should eql(ministry_of_funk) }
    end

    context 'user has an organisation slug set that we don\'t have' do
      subject(:user) { FactoryGirl.create(:user, organisation_slug: "nasa") }

      its(:organisation) { should eql(nil) }
    end
  end

  describe 'gds_transition_manager?' do
    context 'doesn\'t have permission' do
      subject(:user) { FactoryGirl.create(:user, permissions: ["signin"])}

      its(:gds_transition_manager?) { should eql(false) }
    end

    context 'has relevant permission' do
      subject(:user) { FactoryGirl.create(:user, permissions: ["GDS Transition Manager"])}

      its(:gds_transition_manager?) { should eql(true) }
    end
  end
end
