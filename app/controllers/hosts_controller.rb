class HostsController < ActionController::Base
  def index
    @hosts = Host.includes(:site)

    respond_to do |format|
      format.json do
        render json: HostsPresenter.new(@hosts).as_hash.to_json
      end
    end
  end
end
