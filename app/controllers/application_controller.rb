class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit

  before_action :exclude_all_users_except_admins_during_maintenance

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from ActionController::InvalidAuthenticityToken do
    render_error(
      403,
      body: "Invalid authenticity token",
    )
  end

  def user_for_paper_trail
    current_user.name if user_signed_in?
  end

  def info_for_paper_trail
    { user_id: current_user.id } if user_signed_in?
  end

  def render_error(status, options = {})
    @custom_header = options[:header]
    @custom_body = options[:body]
    render "errors/error_#{status}", status:, layout: "error_page"
  end

private

  def verify_authenticity_token
    raise ActionController::InvalidAuthenticityToken unless verified_request?
  end

  def exclude_all_users_except_admins_during_maintenance
    render_error(503) if Rails.application.config.down_for_maintenance && !current_user.admin?
  end
end
