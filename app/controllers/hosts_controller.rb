class HostsController < ActionController::Base
  def index
    @hosts = Host.includes(:site)

    render json: HostsPresenter.new(@hosts).as_hash.to_json
  end
end
