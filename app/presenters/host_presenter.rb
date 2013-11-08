# Generates a hash suitable for exposing a host's hostname and where
# the host is managed, for configuring the CDN
class HostPresenter < Struct.new(:host)
  def as_hash
    {
      managed_by_transition: host.site.managed_by_transition,
      hostname: host.hostname,
    }
  end
end
