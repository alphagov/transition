require 'gds_api/organisations'

module Transition
  module Import
    class WhitehallOrgs
      ##
      # Place to put complete cached copy of orgs API
      def cached_org_path
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

      def each
        organisations.each
      end

      def by_title
        @organisations_hash ||= organisations.inject({}) do |hash, org|
          hash[org.title] = org
          hash
        end
      end
    end
  end
end
