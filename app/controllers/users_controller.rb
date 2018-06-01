# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_s3_direct_post, only: %i[new edit create update]
  skip_before_action :require_login, only: %i[new create]
  before_action :require_admin, only: [:index]

  # GET /users
  # GET /users.json
  def index
    @users = User.page(params[:page]) # don't become User for pagination
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new.becomes(User)
  end

  # GET /users/1/edit
  def edit; end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.type = Member.name
    @user.becomes(User)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        flash[:notice] = "Failed to create: #{@user.errors}"
        format.html { render "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        flash[:notice] = "Failed to update: #{@user.errors}"
        format.html { render "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id]).becomes(User)
    @spotify_authentication = @user.spotify_authentication
  end

  def user_params
    params.require(:user).permit(:email,
                                 :name,
                                 :locale,
                                 :picture,
                                 :password,
                                 :password_confirmation)
  end

  def set_s3_direct_post
    id = @user.present? ? @user.id : SecureRandom.uuid
    @s3_direct_post = S3_BUCKET.presigned_post(key: "profiles/picture/#{id}", success_action_status: "201", acl: "public-read")
  end
end
