class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

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

  def render_error(status)
    render "errors/error_#{status}", status: status, layout: 'error_page'
  end

private
  def verify_authenticity_token
    raise ActionController::InvalidAuthenticityToken unless verified_request?
  end
end
