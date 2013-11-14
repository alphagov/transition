# Generates a hash suitable for exposing a host's hostname and where
# the host is managed, for configuring the CDN, optionally using the
# host's aka_hostname.

class HostPresenter
  def initialize(host, options={})
    @host = host
    @use_aka_hostname = options[:use_aka_hostname]
  end

  def as_hash
    {
      managed_by_transition: @host.site.managed_by_transition,
      hostname: hostname,
    }
  end

private
  def hostname
    @use_aka_hostname ? @host.aka_hostname : @host.hostname
  end
end
