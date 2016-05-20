class ApplicationController < ActionController::Base
  # include CommonAuthentication

  # before_filter :require_signin_permission!
  before_filter :exclude_all_users_except_admins_during_maintenance

  # this is sooo bad.
  before_filter :janky_session_user

  def janky_session_user
    @current_user ||= User.find(session[:user_id])
  rescue
    if @current_user.nil?
      redirect_to home_path
    end
  end

  helper_method :current_user
  def current_user
    @current_user
  end

  def user_signed_in?
    !current_user.nil?
  end

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
    render_error(503) if Rails.application.config.down_for_maintenance && !current_user.admin?
  end
end
