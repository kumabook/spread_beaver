class EntriesController < ApplicationController
  before_action :set_entry    , only: [:show, :show_feedly, :edit, :update, :destroy]
  before_action :set_feed     , only: [:index]
  before_action :set_keyword  , only: [:index]
  before_action :set_tag      , only: [:index]
  before_action :require_admin, only: [:new, :create, :destroy, :update]

  def index
    if @keyword.present?
      @entries = @keyword.entries.includes(:tracks)
                         .order('published DESC')
                         .page(params[:page])
    elsif @tag.present?
      @entries = @tag.entries.includes(:tracks)
                     .order('published DESC')
                     .page(params[:page])
    elsif @feed.present?
      @entries = Entry.includes(:tracks)
                      .where(feed_id: @feed.id)
                      .order('published DESC')
                      .page(params[:page])
    else
      @entries = Entry.includes(:tracks)
                      .order('published DESC')
                      .page(params[:page])
    end
    @user_entries = UserEntry.where(user_id: current_user.id,
                                   entry_id: @entries.map { |e| e.id })
    @entries = [] if @entries.nil?
  end

  def show_feedly
    client = Feedlr::Client.new(sandbox: false)
    @feedlr_entry = client.user_entry(@entry.id)
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
    keywords = Keyword.find(entry_params[:keywords].select { |k| !k.blank? })
    tags     = Tag.find(entry_params[:tags].select { |t| !t.blank? })
    @entry.update_attributes(entry_params.merge({
                                                  keywords: keywords,
                                                      tags: tags
                                                }))
    respond_to do |format|
      if @entry.save
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

  def set_keyword
    @keyword = Keyword.find_by(id: params[:keyword_id])
  end

  def set_tag
    @tag = Tag.find_by(id: params[:tag_id])
  end

  def entry_params
    params.require(:entry).permit(:id, :title, :description, :website,
                                  keywords: [], tags: [])
  end
end
