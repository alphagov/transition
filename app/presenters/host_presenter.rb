# Generates a hash suitable for exposing a host's hostname, for
# configuring the CDN.

class HostPresenter
  def initialize(host)
    @host = host
  end

  def as_hash
    {
      hostname: @host.hostname,
    }
  end
end
