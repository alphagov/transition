require "gds_api/organisations"

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
        if load_orgs_from_yaml?
          load_orgs_from_yaml
        else
          load_orgs_from_api
        end
      end

      def load_orgs_from_yaml?
        @org_yaml_path.present? && File.exist?(@org_yaml_path)
      end

      def load_orgs_from_yaml
        YAML.safe_load(File.read(@org_yaml_path))
      end

      def load_orgs_from_api
        api = GdsApi::Organisations.new(Plek.new.website_root)
        api.organisations.with_subsequent_pages.to_a
      end
    end
  end
end
