require 'spec_helper'
require 'transition/history'

module Transition
  describe History, versioning: true do
    specify { PaperTrail.should be_enabled }

    let(:user) { create :user }

    before do
      PaperTrail.whodunnit = nil
      PaperTrail.controller_info = nil
      Transition::History.set_user!(user)
    end

    describe '.set_user!' do
      it 'sets the controller_info' do
        PaperTrail.controller_info.should eql({ user_id: user.id })
      end

      it 'sets the whodunnit to the user\'s name' do
        PaperTrail.whodunnit.should eql(user.name)
      end
    end

    describe '.clear_user!' do
      before do
        PaperTrail.whodunnit.should eql(user.name)
        Transition::History.clear_user!
      end

      it 'clears the controller_info' do
        PaperTrail.controller_info.should be_nil
      end

      it 'clears the whodunnit' do
        PaperTrail.whodunnit.should be_nil
      end
    end
  end
end
