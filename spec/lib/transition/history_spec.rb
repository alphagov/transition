require "rails_helper"
require "transition/history"

module Transition
  describe History, versioning: true do
    specify { expect(PaperTrail).to be_enabled }

    let(:user) { create :user }

    before do
      PaperTrail.request.whodunnit = nil
      PaperTrail.request.controller_info = nil
      Transition::History.set_user!(user)
    end

    describe ".set_user!" do
      it "sets the controller_info" do
        expect(PaperTrail.request.controller_info).to eql(user_id: user.id)
      end

      it "sets the whodunnit to the user's name" do
        expect(PaperTrail.request.whodunnit).to eql(user.name)
      end
    end

    describe ".clear_user!" do
      before do
        expect(PaperTrail.request.whodunnit).to eql(user.name)
        Transition::History.clear_user!
      end

      it "clears the controller_info" do
        expect(PaperTrail.request.controller_info).to be_nil
      end

      it "clears the whodunnit" do
        expect(PaperTrail.request.whodunnit).to be_nil
      end
    end

    describe ".as_a_user" do
      let(:original_user)       { create :user, name: "Original" }
      let(:user_who_does_stuff) { create :user, name: "Doer of Stuff" }

      before do
        Transition::History.set_user!(original_user)
      end

      it "sets the new user for the block" do
        Transition::History.as_a_user(user_who_does_stuff) do
          expect(PaperTrail.request.whodunnit).to eql(user_who_does_stuff.name)
          expect(PaperTrail.request.controller_info).to eql(user_id: user_who_does_stuff.id)
        end
      end

      it "reverts to the original config afterwards" do
        Transition::History.as_a_user(user_who_does_stuff) {}

        expect(PaperTrail.request.whodunnit).to eql(original_user.name)
        expect(PaperTrail.request.controller_info).to eql(user_id: original_user.id)
      end
    end

    describe ".ensure_user!" do
      context "when PaperTrail is disabled" do
        before { PaperTrail.enabled = false }
        after  { PaperTrail.enabled = true }

        it "does not fail" do
          expect { Transition::History.ensure_user! }.not_to raise_error
        end
      end

      context "when PaperTrail is enabled" do
        context "with a user" do
          it "does not fail" do
            expect { Transition::History.ensure_user! }.not_to raise_error
          end
        end

        context "without a user" do
          before { Transition::History.clear_user! }

          it "fails" do
            expect { Transition::History.ensure_user! }.to \
              raise_error(Transition::History::PaperTrailUserNotSetError)
          end
        end
      end
    end
  end
end
