namespace :import do
  namespace :revert do
    desc "Delete unneeded sites, if they have no data created since the site config import"
    task sites: :environment do |_, args|
      site_abbrs = args.extras.reject(&:empty?)
      if site_abbrs.empty?
        puts "Usage: rake import:revert:sites[abbr_1,abbr_2]"
        abort
      end

      Transition::Import::Revert::Sites.new(site_abbrs).revert_all!
    end

    desc "Delete specified hosts"
    task :hosts, [:hostnames] => :environment do |_, args|
      hosts = args[:hostnames].split(",")
      if hosts.empty?
        puts "Usage: rake import:revert:hosts[host_1,host_2]"
        abort
      end

      Host.where(hostname: hosts).destroy_all
    end
  end
end
