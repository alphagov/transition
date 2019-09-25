require "transition/import/sites"
require "transition/import/organisations"

module Transition
  module Import
    class OrgsSitesHosts
      def self.from_yaml!(mask, whitehall_orgs = nil)
        Organisations.from_whitehall!(whitehall_orgs)
        Sites.new(mask).import!
      end
    end
  end
end
