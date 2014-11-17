require 'gds_api/organisations'

module Transition
  module Import
    ##
    # Behaves like a repo of Whitehall Orgs, indexing by_title
    # and by_slug
    class WhitehallOrgs
      include Enumerable

      # org_yaml_path is only for test usage, so that we can pass in a fixture
      # rather than calling a live API. In production this always calls the
      # live API.
      def initialize(org_yaml_path = nil)
        @org_yaml_path = org_yaml_path
      end

      def organisations
        @organisations ||= begin
          if @org_yaml_path.present? && File.exist?(@org_yaml_path)
            return YAML.load(File.read(@org_yaml_path))
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
