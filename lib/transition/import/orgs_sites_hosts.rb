require 'htmlentities'
require 'transition/import/site_yaml_file'

module Transition
  module Import
    class OrgsSitesHosts
      class NoYamlFound < RuntimeError; end

      def initialize(yaml_mask)
        @yaml_files = Dir.glob(yaml_mask)
        raise NoYamlFound if @yaml_files.empty?
      end

      def import!
        @yaml_files.each do |filename|
          SiteYamlFile.new(filename).import!
        end
      end

      def self.from_redirector_yaml!(yaml_mask)
        OrgsSitesHosts.new(yaml_mask).import!
      end
    end
  end
end
