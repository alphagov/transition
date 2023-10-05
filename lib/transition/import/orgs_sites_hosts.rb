require "transition/import/organisations"

module Transition
  module Import
    class Organisations
      def self.from_yaml!(whitehall_orgs = nil)
        Organisations.from_whitehall!(whitehall_orgs)
      end
    end
  end
end
