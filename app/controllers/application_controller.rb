class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!
  before_filter :set_cache_buster

  before_filter :exclude_all_users_except_admins_during_maintenance

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from ActionController::InvalidAuthenticityToken do
    render_error(403,
                 body: "Invalid authenticity token")
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
    render "errors/error_#{status}", status: status, layout: 'error_page'
  end

  # http://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

private

  def verify_authenticity_token
    raise ActionController::InvalidAuthenticityToken unless verified_request?
  end

  def exclude_all_users_except_admins_during_maintenance
    render_error(503) if Rails.application.config.down_for_maintenance && !current_user.admin?
  end
end
