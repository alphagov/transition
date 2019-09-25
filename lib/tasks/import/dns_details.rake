require "transition/import/dns_details"
require "transition/distributed_lock"

namespace :import do
  desc "Look up DNS details for all hosts"
  task dns_details: :environment do
    Transition::DistributedLock.new("dns_details").lock do
      Transition::Import::DnsDetails.from_nameserver!
    end
  end
end
