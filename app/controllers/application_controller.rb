class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

  before_filter :exclude_all_users_except_admins_during_maintenance

  protect_from_forgery

  rescue_from ActionController::InvalidAuthenticityToken do
    render text: "Invalid authenticity token", status: 403
  end

  def user_for_paper_trail
    current_user.name if user_signed_in?
  end

  def info_for_paper_trail
    { user_id: current_user.id } if user_signed_in?
  end

  def render_error(status, options={})
    @custom_header = options[:header]
    @custom_body = options[:body]
    render "errors/error_#{status}", status: status, layout: 'error_page'
  end

private
  def verify_authenticity_token
    raise ActionController::InvalidAuthenticityToken unless verified_request?
  end

  def exclude_all_users_except_admins_during_maintenance
    render_error(503) if Transition::Application.config.down_for_maintenance && !current_user.admin?
  end
end
