require "transition/import/sites"
require "transition/import/organisations"

module Transition
  module Import
    class Organisations
      def self.from_yaml!(whitehall_orgs = nil)
        Organisations.from_whitehall!(whitehall_orgs)
      end
    end

    class SitesHosts
      def self.from_yaml!(mask)
        Sites.new(mask).import!
      end
    end
  end
end
