module Transition
  module History
    class PaperTrailUserNotSetError < RuntimeError
      def to_s
        "Both PaperTrail.request.controller_info and PaperTrail.request.whodunnit should be "\
        "set. controller_info #{PaperTrail.request.controller_info || '(nil)'} should be a hash "\
        "containing user_id, and whodunnit #{PaperTrail.request.whodunnit || '(nil)'} should be "\
        "the user's name."
      end
    end

    def self.set_user!(user)
      ::PaperTrail.request.whodunnit = user.name
      ::PaperTrail.request.controller_info = { user_id: user.id }
    end

    def self.clear_user!
      ::PaperTrail.request.whodunnit = nil
      ::PaperTrail.request.controller_info = nil
    end

    def self.as_a_user(user)
      original_whodunnit = ::PaperTrail.request.whodunnit
      original_controller_info = ::PaperTrail.request.controller_info
      set_user!(user)
      begin
        yield
      ensure
        ::PaperTrail.request.whodunnit = original_whodunnit
        ::PaperTrail.request.controller_info = original_controller_info
      end
    end

    def self.ensure_user!
      if PaperTrail.enabled? &&
          PaperTrail.request.whodunnit.nil? &&
          PaperTrail.request.controller_info.try(:[], :user_id).nil?
        raise PaperTrailUserNotSetError
      end
    end
  end
end
