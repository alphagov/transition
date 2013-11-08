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

  describe 'admin?' do
    context 'doesn\'t have permission' do
      subject(:user) { FactoryGirl.create(:user, permissions: ["signin"])}

      its(:admin?) { should eql(false) }
    end

    context 'has relevant permission' do
      subject(:user) { FactoryGirl.create(:admin) }

      its(:admin?) { should eql(true) }
    end
  end

  describe 'can_edit?' do
    let(:ministry_of_funk) {
      FactoryGirl.create(:organisation, whitehall_slug: 'ministry-of-funk')
    }
    let(:agency_of_soul) {
      FactoryGirl.create(:organisation, whitehall_slug: 'agency-of-soul', parent: ministry_of_funk)
    }

    context 'user is an admin' do
      subject(:user) { FactoryGirl.create(:admin) }

      it 'lets them edit anything' do
        user.can_edit?(ministry_of_funk).should eql(true)
      end
    end

    context 'user is not a member of any organisation' do
      subject(:user) { FactoryGirl.create(:user) }

      it 'should return false' do
        user.can_edit?(ministry_of_funk).should eql(false)
      end
    end

    context 'user is a member of the parent organisation' do
      subject(:user) { FactoryGirl.create(:user, organisation_slug: "ministry-of-funk") }

      it 'should return true' do
        user.can_edit?(agency_of_soul).should eql(true)
      end
    end

    context 'user is a member of a child organisation' do
      subject(:user) { FactoryGirl.create(:user, organisation_slug: "agency-of-soul") }

      it 'should return false' do
        user.can_edit?(ministry_of_funk).should eql(false)
      end
    end
  end
end
