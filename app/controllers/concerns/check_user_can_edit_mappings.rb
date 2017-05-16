module CheckUserCanEditMappings
  def checks_user_can_edit(options = {})
    class_eval do
      include CheckUserCanEditMappings

      before_action :check_user_can_edit_mappings, options
    end
  end

protected

  def check_user_can_edit_mappings
    unless current_user.can_edit_site?(@site)
      message = "You don't have permission to edit mappings for #{@site.default_host.hostname}"
      redirect_to site_mappings_path(site_id: @site), alert: message
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.extend CheckUserCanEditMappings
end
