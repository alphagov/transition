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

          if cname_record = record(host.hostname, Resolv::DNS::Resource::IN::CNAME)
            host.cname      = cname_record.name.to_s
            host.ip_address = nil
            host.ttl        = cname_record.ttl
          elsif a_record = record(host.hostname, Resolv::DNS::Resource::IN::A)
            host.cname      = nil
            host.ip_address = a_record.address.to_s
            host.ttl        = a_record.ttl
          end
          host.save!
        end
      end

      def record(hostname, type)
        resolver.getresource(hostname, type)
      rescue Resolv::ResolvError
        # Can be raised if the host didn't exist, or because we explicitly
        # asked for a type of record it doesn't have.
        nil
      end

      def self.from_nameserver!(hosts = Host.all)
        DnsDetails.new(hosts).import!
      end
    end
  end
end
