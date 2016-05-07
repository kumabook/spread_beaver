class ReadEntriesController < ApplicationController
  include UserEntryControllable

  private

    def set_user_entry
      @user_entry = ReadEntry.find(params[:id])
    end

    def new_user_entry
      ReadEntry.new(user_entry_params)
    end

    def user_entry_params
      params.require(:user_entry).permit(:user_id, :entry_id)
    end
end
