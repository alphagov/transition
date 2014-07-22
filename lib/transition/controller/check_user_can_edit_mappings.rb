module Transition
  module Controller
    module CheckUserCanEditMappings
      def check_user_can_edit
        unless current_user.can_edit_site?(@site)
          message = "You don't have permission to edit mappings for #{@site.default_host.hostname}"
          redirect_to site_mappings_path(@site), alert: message
        end
      end
    end
  end
end
