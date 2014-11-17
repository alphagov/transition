require 'gds_api/organisations'

module Transition
  module Import
    ##
    # Behaves like a repo of Whitehall Orgs, indexing by_title
    # and by_slug
    class WhitehallOrgs
      include Enumerable

      def initialize(cached_org_path = nil)
        @cached_org_path = cached_org_path
      end

      def organisations
        @organisations ||= begin
          if @cached_org_path.present? && File.exist?(@cached_org_path)
            return YAML.load(File.read(@cached_org_path))
          end

          api = GdsApi::Organisations.new(Plek.current.find('whitehall-admin'))
          api.organisations.with_subsequent_pages.to_a
        end
      end

      def each(&block)
        organisations.each &block
      end

      def by_id
        @by_id ||= organisations.inject({}) do |hash, org|
          hash[org.id] = org
          hash
        end
      end
    end
  end
end
