module UserEntryControllable
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval {
      before_action :set_user_entry, only: [:destroy]
    }
  end
  module ClassMethods
  end

  def create
    @user_entry = new_user_entry

    respond_to do |format|
      to = request.referer ? :back : entries_path
      if @user_entry.save
        format.html { redirect_to to, notice: 'UserEntry was successfully created.' }
        format.json { render :show, status: :created, location: @user_entry }
      else
        format.html { redirect_to to, notice: @user_entry.errors }
        format.json { render json: @user_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      to = request.referer ? :back : entries_path
      if @user_entry.destroy
        format.html { redirect_to to, notice: 'UserEntry was successfully destroyed.' }
        format.json { render :show, status: :created, location: @user_entry }
      else
        format.html { redirect_to to, notice: @user_entry.errors }
        format.json { render json: @user_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_user_entry
      @user_entry = UserEntry.find(params[:id])
    end

    def new_user_entry
      UserEntry.new(user_entry_params)
    end

    def user_entry_params
      params.require(:user_entry).permit(:user_id, :entry_id)
    end
end
