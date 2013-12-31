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
          # Override indeterminate status if at least one host is pointing at us
          when (site.hosts.map { |h| h.redirected_by_gds? }).any?
            'live'
          # 'indeterminate' is only ever set by hand. It is for sites which
          # are either:
          #   * redirected by the supplier
          #   * redirected to the AKA version of the domain, which points at
          #     us
          #
          # We can't automatically detect these scenarios from the hosts' DNS
          # details, so they have to be managed manually. We should not update
          # the status if it has been set to 'indeterminate' and no hosts point
          # at us.
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
