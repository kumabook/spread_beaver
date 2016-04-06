class PreferencesController < ApplicationController
  before_action :set_preference, only: [:show, :update, :edit, :destroy]
  before_action :set_user

  # GET /preferences
  # GET /preferences.json
  def index
    @preferences = Preference.all
  end

  # GET /preferences/new
  def new
    @preference = Preference.new
  end


  # POST /preferences
  # POST /preferences.json
  def create
    @preference      = Preference.new(preference_params)
    @preference.user = @user
    respond_to do |format|
      if @preference.save
        format.html { redirect_to user_preferences_path(@user), notice: 'Preference was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /preferences/1
  # PATCH/PUT /preferences/1.json
  def update
    @preference = Preference.find(params[:id])

    if @preference.update(preference_params)

    else

    end
  end

  # DELETE /preferences/1
  # DELETE /preferences/1.json
  def destroy
    respond_to do |format|
      if @preference.destroy
        format.html { redirect_to user_preferences_path, notice: 'Preference was successfully destroyed.' }
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
