require "resolv"

module Transition
  module Import
    ##
    # Augments Host models with real DNS info
    class DnsDetails
      NAMESERVERS = ["8.8.8.8", "8.8.4.4"].freeze

      attr_accessor :hosts, :resolver

      def initialize(hosts)
        self.resolver = Resolv::DNS.new(nameserver: NAMESERVERS)
        self.hosts = hosts
      end

      def import!
        hosts.each do |host|
          $stderr.print "."

          add_cname_record_details(host) || add_a_record_details(host)

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

    private

      def add_cname_record_details(host)
        cname_record = record(host.hostname, Resolv::DNS::Resource::IN::CNAME)
        if cname_record
          host.cname      = cname_record.name.to_s
          host.ip_address = nil
          host.ttl        = cname_record.ttl
        end
        cname_record.present?
      end

      def add_a_record_details(host)
        a_record = record(host.hostname, Resolv::DNS::Resource::IN::A)
        if a_record
          host.cname      = nil
          host.ip_address = a_record.address.to_s
          host.ttl        = a_record.ttl
        end
        a_record.present?
      end
    end
  end
end
