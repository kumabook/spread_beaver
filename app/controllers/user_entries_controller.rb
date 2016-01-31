class UserEntriesController < ApplicationController
  before_action :set_user_entry, only: [:show, :update, :destroy]

  # GET /user_entries
  # GET /user_entries.json
  def index
    @user_entries = UserEntry.all

    render json: @user_entries
  end

  # GET /user_entries/1
  # GET /user_entries/1.json
  def show
    render json: @user_entry
  end

  # POST /user_entries
  # POST /user_entries.json
  def create
    @user_entry = UserEntry.new(user_entry_params)

    if @user_entry.save
      render json: @user_entry, status: :created, location: @user_entry
    else
      render json: @user_entry.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_entries/1
  # PATCH/PUT /user_entries/1.json
  def update
    @user_entry = UserEntry.find(params[:id])

    if @user_entry.update(user_entry_params)
      head :no_content
    else
      render json: @user_entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_entries/1
  # DELETE /user_entries/1.json
  def destroy
    @user_entry.destroy

    head :no_content
  end

  private

    def set_user_entry
      @user_entry = UserEntry.find(params[:id])
    end

    def user_entry_params
      params.require(:user_entry).permit(:user_id, :entry_id)
    end
end
