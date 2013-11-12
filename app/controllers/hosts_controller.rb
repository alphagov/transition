class HostsController < ActionController::Base
  def index
    @hosts = Host.includes(:site)

    respond_to do |format|
      format.json do
        presented_hosts = @hosts.inject([]) do |hosts, host|
          hosts << HostPresenter.new(host).as_hash
          hosts << HostPresenter.new(host, aka: true).as_hash
        end
        render json: presented_hosts.to_json
      end
    end
  end
end
