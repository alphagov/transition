class HostsController < ApplicationController
  def index
    @hosts = Host.includes(:site)

    respond_to do |format|
      format.json do
        presented_hosts = @hosts.map { |host| HostPresenter.new(host).as_hash }
        render json: presented_hosts.to_json
      end
    end
  end
end
