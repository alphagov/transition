module Transition
  module History
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
