class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

  protect_from_forgery

  def user_for_paper_trail
    current_user.name if user_signed_in?
  end

  def info_for_paper_trail
    { user_id: current_user.id } if user_signed_in?
  end
end
