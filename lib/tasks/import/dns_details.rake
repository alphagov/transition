require 'transition/import/dns_details'

namespace :import do
  desc 'Look up CNAME details for all hosts'
  task :dns_details => :environment do
    Transition::Import::DnsDetails.from_nameserver!
  end
end
