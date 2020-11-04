class HostsController < ActionController::API
  def index
    @hosts = Host.with_cname_or_ip_address.order(:hostname)
    expires_now
    render json: HostsPresenter.new(@hosts).as_hash.to_json
  end
end
