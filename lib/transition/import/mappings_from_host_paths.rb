require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class MappingsFromHostPaths
      extend Transition::Import::ConsoleJobWrapper

      def self.refresh!(site)
        start 'Creating mappings from HostPaths' do
          Transition::History.as_a_user(user) do
            site_paths = site.host_paths.where('mapping_id is null').group('c14n_path_hash').pluck(:path)
            site_paths.each do |uncanonicalized_path|
              # Try to create them (there may be duplicates in the set and they may
              # already exist).
              if site.mappings.create(path: uncanonicalized_path, type: 'unresolved')
                $stderr.print '.'
              end
            end
          end
        end
      end

      def self.user
        User.where(email: 'logs-mappings-robot@dummy.com').first_or_create! do |user|
          user.name  = 'Logs mappings robot'
          user.is_robot = true
        end
      end
    end
  end
end
