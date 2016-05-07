class UserEntriesController < ApplicationController
  before_action :set_user_entry, only: [:destroy]

  # POST /user_entries
  # POST /user_entries.json
  def create
    @user_entry = UserEntry.new(user_entry_params)

    respond_to do |format|
      if @user_entry.save
        format.html { redirect_to entries_path, notice: 'UserEntry was successfully created.' }
        format.json { render :show, status: :created, location: @user_entry }
      else
        format.html { redirect_to entries_path, notice: @user_entry.errors }
        format.json { render json: @user_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_entries/1
  # DELETE /user_entries/1.json
  def destroy
    respond_to do |format|
      if @user_entry.destroy
        format.html { redirect_to entries_path, notice: 'UserEntry was successfully destroyed.' }
        format.json { render :show, status: :created, location: @user_entry }
      else
        format.html { redirect_to entries_path, notice: @user_entry.errors }
        format.json { render json: @user_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_user_entry
      @user_entry = UserEntry.find(params[:id])
    end

    def user_entry_params
      params.require(:user_entry).permit(:user_id, :entry_id)
    end
end
