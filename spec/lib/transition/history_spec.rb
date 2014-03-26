require 'spec_helper'
require 'transition/history'

module Transition
  describe History do
    describe '.set_user!', versioning: true do
      specify { PaperTrail.should be_enabled }

      let(:user) { create :user }

      before do
        PaperTrail.whodunnit = nil
        PaperTrail.controller_info = nil
        Transition::History.set_user!(user)
      end

      it 'sets the controller_info' do
        PaperTrail.controller_info.should eql({ user_id: user.id })
      end

      it 'sets the whodunnit to the user\'s name' do
        PaperTrail.whodunnit.should eql(user.name)
      end
    end
  end
end
