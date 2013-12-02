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

      ##
      # Place to put complete cached copy of orgs API.
      # Cache expires when the date changes, so could be valid
      # for up to 24 hours.
      def cached_org_path
        @cached_org_path ||=
          "/tmp/all_whitehall_orgs-#{DateTime.now.strftime('%Y-%m-%d')}.yaml"
      end

      def organisations
        @organisations ||= begin
          return YAML.load(File.read(cached_org_path)) if File.exist?(cached_org_path)

          api = GdsApi::Organisations.new(Plek.current.find('whitehall-admin'))
          api.organisations.with_subsequent_pages.to_a.tap do |orgs|
            File.open(cached_org_path, 'w') { |f| f.write(YAML.dump(orgs)) }
          end
        end
      end

      def each(&block)
        organisations.each &block
      end

      def by_title
        @organisations_hash ||= organisations.inject({}) do |hash, org|
          hash[org.title] = org
          hash
        end
      end

      def by_id
        @organisations_hash ||= organisations.inject({}) do |hash, org|
          hash[org.id] = org
          hash
        end
      end
    end
  end
end
