# rubocop:disable Rails/ApplicationController
class HostsController < ActionController::Base
  def index
    @hosts = Host.with_cname_or_ip_address.order(:hostname)

    render json: HostsPresenter.new(@hosts).as_hash.to_json
  end
end
# rubocop:enable Rails/ApplicationController
