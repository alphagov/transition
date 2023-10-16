require "gds_api/organisations"

module Transition
  module Import
    ##
    # Behaves like a repo of Whitehall Orgs, indexing by_title
    # and by_slug
    class WhitehallOrgs
      include Enumerable

      def organisations
        @organisations ||= load_orgs
      end

      def each(&block)
        organisations.each(&block)
      end

      def by_id
        @by_id ||= organisations.index_by do |org|
          org["id"]
        end
      end

    private

      def load_orgs
        api = GdsApi::Organisations.new(Plek.website_root)
        api.organisations.with_subsequent_pages.to_a
      end
    end
  end
end
