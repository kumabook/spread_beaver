class EntriesController < ApplicationController
  include LikableController
  include SavableController
  include ReadableController

  before_action :set_entry    , only: [:show, :show_feedly, :crawl, :edit, :update, :destroy]
  before_action :set_feed     , only: [:index]
  before_action :set_keyword  , only: [:index]
  before_action :set_tag      , only: [:index]
  before_action :require_admin, only: [:new, :create, :destroy, :update]

  def index
    if @keyword.present?
      @entries = @keyword.entries
                         .order('published DESC')
                         .page(params[:page])
    elsif @tag.present?
      @entries = @tag.entries
                     .order('published DESC')
                     .page(params[:page])
    elsif @feed.present?
      @entries = Entry.where(feed_id: @feed.id)
                      .order('published DESC')
                      .page(params[:page])
    else
      @entries = Entry.order('published DESC')
                      .page(params[:page])
    end
    Entry.set_count_of_enclosures(@entries)
    @liked_entries = LikedEntry.where(user_id: current_user.id,
                                      entry_id: @entries.map { |e| e.id })
    @saved_entries = SavedEntry.where(user_id: current_user.id,
                                      entry_id: @entries.map { |e| e.id })
    @read_entries  = ReadEntry.where(user_id: current_user.id,
                                     entry_id: @entries.map { |e| e.id })
    @entries = [] if @entries.nil?
  end

  def show
  end

  def show_feedly
    client = Feedlr::Client.new
    @feedlr_entry = client.user_entry(@entry.id)
  end

  def crawl
    @entry.crawl
    respond_to do |format|
      format.html {
        redirect_to entry_path(@entry), notice: 'Entry was successfully crawled.'
      }
    end
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
        flash[:notice] = 'Failed to create'
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
    tags     = []
    keywords = []
    if entry_params[:keywords].present?
      keywords = Keyword.find(entry_params[:keywords].select { |k| !k.blank? })
    end
    if entry_params[:tags].present?
      tags     = Tag.find(entry_params[:tags].select { |t| !t.blank? })
    end
    @entry.update_attributes(entry_params.merge({
                                                  keywords: keywords,
                                                      tags: tags
                                                }))
    respond_to do |format|
      if @entry.save
        format.html { redirect_to entry_path(@entry), notice: 'Entry was successfully updated.' }
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

  def user_item_params
    target_id  = params["#{model_class.name.downcase}_id"]
    target_key = "#{model_class.table_name.singularize}_id".to_sym
    {
      :user_id   => current_user.id,
      target_key => target_id,
    }
  end

  def entry_params
    params.require(:entry).permit(:id,
                                  :title,
                                  :content,
                                  :summary,
                                  :author,
                                  :alternate,
                                  :origin,
                                  :visual,
                                  :categories,
                                  :unread,
                                  :engagement,
                                  :actionTimestamp,
                                  :enclosure,
                                  :fingerprint,
                                  :originId,
                                  :sid,
                                  :crawled,
                                  :recrawled,
                                  :published,
                                  :updated,
                                  :feed_id,
                                  keywords: [],
                                  tags: [])
  end
end
