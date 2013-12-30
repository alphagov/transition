module Transition
  module Import
    ##
    # Updates transition_status on sites using hosts' DNS details
    class SiteTransitionStatus

      attr_accessor :sites

      def initialize(hosts)
        site_ids = hosts.map { |h| h.site_id }
        self.sites = Site.where(id: site_ids.uniq)
      end

      def update_sites!
        sites.each do |site|
          site.transition_status = case
          when (site.hosts.map { |h| h.redirected_by_gds? }).any?
            # Override indeterminate status if at least one host is pointing at us
            'live'
          when site.transition_status == 'indeterminate'
            'indeterminate'
          else
            'pre-transition'
          end
          site.save!
        end
      end

      def self.from_hosts!(hosts = Host.all)
        SiteTransitionStatus.new(hosts).update_sites!
      end
    end
  end
end
