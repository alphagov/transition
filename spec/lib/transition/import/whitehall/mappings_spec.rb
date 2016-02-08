require 'rails_helper'
require 'transition/import/whitehall/mappings'

describe Transition::Import::Whitehall::Mappings do
  describe 'as_user' do
    subject { Transition::Import::Whitehall::Mappings.new({ filename: 'foo' }).send(:as_user) }

    context 'when another user already exists' do
      let!(:human) { create(:user, email: 'human_user@example.com', is_robot: false) }

      describe '#email' do
        subject { super().email }
        it { is_expected.to eql(Transition::Import::Whitehall::Mappings::AS_USER_EMAIL) }
      end

      describe '#is_robot' do
        subject { super().is_robot }
        it { is_expected.to be_truthy }
      end
    end
  end
end
