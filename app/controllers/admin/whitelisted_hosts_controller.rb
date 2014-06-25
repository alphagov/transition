class Admin::WhitelistedHostsController < Admin::AdminController
  include PaperTrail::Rails::Controller

  def index
    @whitelisted_hosts = WhitelistedHost.order(:hostname)
  end

  def new
    @whitelisted_host = WhitelistedHost.new
  end

  def create
    @whitelisted_host = WhitelistedHost.new(params[:whitelisted_host])
    if @whitelisted_host.save
      redirect_to admin_whitelisted_hosts_path, flash: { success: "#{@whitelisted_host.hostname} added to whitelist.",
                                                         hostname: @whitelisted_host.hostname }
    else
      render :new
    end
  end
end
