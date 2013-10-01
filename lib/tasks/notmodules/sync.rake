require 'yaml'

##
# Git submodules. Yuck.
# We still want to say what dependencies we have on other repos, though.
# Keep it in a cool, DRY place.
# (a file called .notmodules.yaml)
#
class NotModules
  FILENAME = '.notmodules.yaml'

  include Singleton

  def yaml
    @yaml ||= YAML.load(File.read(FILENAME)) or raise RuntimeError, "Couldn't load #{FILENAME}"
  end

  def modules
    @modules ||= yaml.map { |m| Module.new(m['path'], m['url']) }
  end

  class Module < Struct.new(:path, :url)
    def exists?
      Dir.exists?(path)
    end

    def clone!
      `git clone #{url} #{path} --depth=1`
    end

    def pull!
      `cd #{path} && git pull`
    end

    def sync!
      exists? ? pull! : clone!
    end

    def rev
      (`cd #{path} && git rev-parse HEAD`).chomp
    end

    def to_s
      "#{path} -> #{url}#{exists? ? " (#{rev})" : ''}"
    end
  end
end

namespace :notmodules do
  desc '`git pull` or `git clone` all notmodules as necessary'
  task :sync do
    NotModules.instance.modules.each { |m| m.sync! }
  end

  desc 'list all things that definitely aren\'t git submodules'
  task :list do
    NotModules.instance.modules.each { |m| puts m }
  end
end

task :notmodules => 'notmodules:list'
