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

    def self.as_a_user(user)
      original_whodunnit = ::PaperTrail.whodunnit
      original_controller_info = ::PaperTrail.controller_info
      self.set_user!(user)
      begin
        yield
      ensure
        ::PaperTrail.whodunnit = original_whodunnit
        ::PaperTrail.controller_info = original_controller_info
      end
    end

    def self.ensure_user!
      if PaperTrail.enabled? &&
          PaperTrail.whodunnit.nil? &&
          PaperTrail.controller_info.try(:[], :user_id).nil?
        raise PaperTrailUserNotSetError
      end
    end
  end
end
