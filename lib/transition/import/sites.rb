require 'transition/import/site_yaml_file'

module Transition
  module Import
    class Sites
      class NoYamlFound < RuntimeError; end

      def initialize(yaml_mask)
        @yaml_files = Dir.glob(yaml_mask)
        raise NoYamlFound if @yaml_files.empty?
      end

      def import!
        sites.each { |s| s.import! }
      end

      def sites
        @sites ||= @yaml_files.inject([]) do |sites, filename|
          site_yaml = YAML::load(File.read(filename))
          sites << SiteYamlFile.new(site_yaml, self)
        end
      end
    end
  end
end
