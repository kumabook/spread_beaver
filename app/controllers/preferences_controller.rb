# frozen_string_literal: true
class PreferencesController < ApplicationController
  before_action :set_preference, only: %i[show update edit destroy]
  before_action :set_user

  def index
    @preferences = Preference.where(user: @user)
  end

  # GET /preferences/new
  def new
    @preference = Preference.new(user: @user)
  end

  def create
    @preference      = Preference.new(preference_params)
    @preference.user = @user
    respond_to do |format|
      if @preference.save
        format.html { redirect_to user_preferences_path(@user), notice: "Preference was successfully created." }
      else
        format.html { render "new" }
      end
    end
  end

  def edit; end

  def update
    @preference = Preference.find(params[:id])
    respond_to do |format|
      if @preference.update(preference_params)
        format.html { redirect_to user_preferences_path(@user), notice: "Preference was successfully updated." }
      else
        format.html { render "edit" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @preference.destroy
        format.html { redirect_to user_preferences_path, notice: "Preference was successfully destroyed." }
      else
        format.html { redirect_to user_preferences_path, notice: @preference.errors }
      end
    end

  end

  private

  def set_user
    @user = User.find(params[:user_id]).becomes(User)
  end

  def set_preference
    @preference = Preference.find(params[:id])
  end

  def preference_params
    params[:preference].permit(:key, :value)
  end
end
