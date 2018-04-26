# frozen_string_literal: true
class UserSessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy]

  def new; end

  def create
    if @user = login(params[:email], params[:password])
      redirect_back_or_to(:users, notice: "Login successful")
    else
      flash.now[:alert] = "Login failed"
      render "new"
    end
  end

  def destroy
    logout
    redirect_to(:users, notice: "Logged out!")
  end
end
