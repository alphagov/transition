require 'transition/import/whitehall/mappings'

describe Transition::Import::Whitehall::Mappings do
  describe 'as_user' do
    subject { Transition::Import::Whitehall::Mappings.new({ filename: 'foo' }).send(:as_user) }

    context 'when another user already exists' do
      let!(:human) { create(:user, email: 'human_user@example.com', is_robot: false) }

      its(:email)    { should eql(Transition::Import::Whitehall::Mappings::AS_USER_EMAIL) }
      its(:is_robot) { should be_true }
    end
  end
end
