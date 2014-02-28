require 'resolv'

module Transition
  module Import
    ##
    # Augments Host models with real DNS info
    class DnsDetails
      NAMESERVERS = ['8.8.8.8', '8.8.4.4']

      attr_accessor :hosts, :resolver

      def initialize(hosts)
        self.resolver = Resolv::DNS.new(nameserver: NAMESERVERS)
        self.hosts = hosts
      end

      def import!
        hosts.each do |host|
          $stderr.print '.'
          begin
            cname_record = resolver.getresource(host.hostname, Resolv::DNS::Resource::IN::CNAME)
          rescue Resolv::ResolvError
            # Can be raised if the host didn't exist, or because we explicitly
            # asked for a CNAME record and it doesn't have one.
            next
          end
          host.cname = cname_record.name.to_s
          host.ttl   = cname_record.ttl
          host.save!
        end
      end

      def self.from_nameserver!(hosts = Host.all)
        DnsDetails.new(hosts).import!
      end
    end
  end
end
