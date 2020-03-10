require "transition/history"

Before do
  Transition::History.clear_user!
end

module Helpers
  module PaperTrail
    def with_papertrail_disabled(&block)
      was_enabled = ::PaperTrail.enabled?
      begin
        ::PaperTrail.enabled = false
        block.call
      ensure
        ::PaperTrail.enabled = was_enabled
      end
    end
  end
end

World(Helpers::PaperTrail)
