class HostsController < ActionController::Base
  def index
    @hosts = Host.all.order(:hostname)

    render json: HostsPresenter.new(@hosts).as_hash.to_json
  end
end
