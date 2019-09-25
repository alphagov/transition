class Admin::AdminController < ApplicationController
  before_action :check_user_is_admin

protected

  def check_user_is_admin
    unless current_user.admin?
      message = "Only admins can access that."
      redirect_to root_path, alert: message
    end
  end
end
