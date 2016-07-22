class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login

  protected
  def admin?
    current_user && current_user.admin?
  end

  def require_admin
    unless admin?
      redirect_to root_path
    end
  end

  private
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end
end
