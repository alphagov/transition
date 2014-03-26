module Transition
  module History
    class PaperTrailUserNotSetError < RuntimeError
      def to_s
        'Both PaperTrail.controller_info and PaperTrail.whodunnit should be '\
        "set. controller_info #{PaperTrail.controller_info || '(nil)'} should be a hash "\
        "containing user_id, and whodunnit #{PaperTrail.whodunnit || '(nil)'} should be "\
        'the user\'s name.'
      end
    end

    def self.set_user!(user)
      ::PaperTrail.whodunnit = user.name
      ::PaperTrail.controller_info = { user_id: user.id }
    end

    def self.clear_user!
      ::PaperTrail.whodunnit = nil
      ::PaperTrail.controller_info = nil
    end
  end
end
