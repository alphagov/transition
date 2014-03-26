module Transition
  module History
    def self.set_user!(user)
      ::PaperTrail.whodunnit = user.name
      ::PaperTrail.controller_info = { user_id: user.id }
    end
  end
end
