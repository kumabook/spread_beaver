class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]
  before_action :set_feed, only: [:index]
  before_action :require_admin, only: [:new, :create, :destroy, :update]

  def index
    if @feed.nil?
      @entries = Entry.all.includes(:tracks)
      @user_entries = UserEntry.where(user_id: current_user.id)
    else
      @entries = Entry.includes(:tracks).where(feed_id: @feed.id)
      @user_entries = UserEntry.where(user_id: current_user.id)
    end
    @entries = [] if @entries.nil?
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)
    respond_to do |format|
      if @entry.save
        format.html { redirect_to entries_path, notice: 'Entry was successfully created.' }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to entries_path, notice: 'Feed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to entries_path, notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  private

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def set_feed
    @feed = Feed.find(CGI.unescape params[:feed_id]) if params[:feed_id].present?
  end

  def entry_params
    params.require(:entry).permit(:id, :title, :description, :website)
  end
end
