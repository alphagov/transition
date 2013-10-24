require 'transition/import/dns_details'

namespace :import do
  task :dns_details => :environment do
    Transition::Import::DnsDetails.from_nameserver!
  end
end
