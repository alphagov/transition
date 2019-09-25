class HostsPresenter
  def initialize(hosts)
    @hosts = hosts
  end

  def as_hash
    {
      results: results,
      total: results.count,
      _response_info: {
        status: "ok",
      },
    }
  end

private

  def results
    @results ||= @hosts.map { |host| HostPresenter.new(host).as_hash }
  end
end
