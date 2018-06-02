# frozen_string_literal: true

class AuthenticationsController < ApplicationController
  before_action :set_authentication, only: :destroy
  skip_before_action :require_login, only: :callback

  def callback
    auth   = request.env["omniauth.auth"]
    action = request.env["omniauth.params"]["action"]
    case action
    when "connect"
      user = current_user.becomes(User)
      if user.nil?
        redirect_to root_path, notice: "Please login first"
        return
      end
      user.connect_with_auth(auth)
      redirect_to edit_user_path(user), notice: "Account was successfully connected."
    when "login"
      authentication = Authentication.find_by_auth(auth)
      if authentication.nil? || authentication.user.nil?
        redirect_to root_path, notice: "This account isn't connected any user"
        return
      end
      authentication.update_with_auth(auth)
      auto_login(authentication.user)
      redirect_back_or_to(:users, notice: "Login successful")
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to edit_user_path(user), notice: "This account connected with another user"
  end

  def destroy
    @authentication.destroy
    respond_to do |format|
      format.html {
        redirect_to edit_user_path(@authentication.user),
                    notice: "Authentication was successfully destroyed."
      }
      format.json { head :no_content }
    end
  end

  private

  def set_authentication
    @authentication = Authentication.find(params[:id])
  end
end
