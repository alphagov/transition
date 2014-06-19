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

    describe '.as_a_user' do
      let(:original_user)       { create :user, name: 'Original' }
      let(:user_who_does_stuff) { create :user, name: 'Doer of Stuff' }

      before do
        Transition::History.set_user!(original_user)
      end

      it 'sets the new user for the block' do
        Transition::History.as_a_user(user_who_does_stuff) do
          PaperTrail.whodunnit.should eql(user_who_does_stuff.name)
          PaperTrail.controller_info.should eql({ user_id: user_who_does_stuff.id })
        end
      end

      it 'reverts to the original config afterwards' do
        Transition::History.as_a_user(user_who_does_stuff) { }

        PaperTrail.whodunnit.should eql(original_user.name)
        PaperTrail.controller_info.should eql({ user_id: original_user.id })
      end
    end

    describe '.ensure_user!' do
      context 'when PaperTrail is disabled' do
        before { PaperTrail.enabled = false }
        after  { PaperTrail.enabled = true }

        it 'should not raise an exception' do
          expect { Transition::History.ensure_user! }.not_to raise_error
        end
      end

      context 'when PaperTrail is enabled' do
        context 'with the correct configuration' do
          it 'should not raise an exception' do
            expect { Transition::History.ensure_user! }.not_to raise_error
          end
        end

        context 'without the correct configuration' do
          before { Transition::History.clear_user! }

          it 'should fail with an exception' do
            expect { Transition::History.ensure_user! }.to raise_error
          end
        end
      end
    end
  end
end
