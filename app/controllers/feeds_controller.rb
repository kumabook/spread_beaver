class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :show_feedly, :edit, :update, :destroy]
  before_action :set_topic, only: [:index]
  before_action :require_admin, only: [:new, :create, :destroy, :update]

  def index
    @title = 'Feeds'
    if @topic.present?
      @feeds = @topic.feeds.order('velocity DESC')
    else
      @feeds = Feed.all.order('velocity DESC')
    end
    @subscriptions = Subscription.where(user_id: current_user.id)
  end

  def show
    render action: "show", formats: :html
  end

  def show_feedly
    client = Feedlr::Client.new
    @feedlr_feed = client.feed(@feed.id)
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.find_or_create_with_ids(["feed/#{feed_params[:id]}"]).first
    respond_to do |format|
      if @feed.nil?
        @feed = Feed.new
        flash[:notice] = 'The url is invalid'
        format.html { render :new }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      elsif @feed.save
        format.html { redirect_to feeds_path, notice: 'Feed was successfully created.' }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { redirect_to feeds_path, notice: @feed.errors }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @feed.destroy
        format.html { redirect_to feeds_path, notice: 'Feed was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to feeds_path, notice: @feed.errors }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    topics = Topic.find((feed_params[:topics] || []).select { |t| !t.blank? })
    @feed.update_attributes(feed_params.merge({topics: topics}))
    respond_to do |format|
      if @feed.save
        format.html { redirect_to feed_path(@feed.escape), notice: 'Feed was successfully updated.' }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  private

  def set_feed
    @feed = Feed.includes(:topics).find(CGI.unescape(params[:id]))
  end

  def set_topic
    @topic = Topic.find_by(id: params[:topic_id])
  end

  def feed_params
    params.require(:feed).permit(:id, :title, :description, :website, :velocity,
                                 :visualUrl, :coverUrl, :iconUrl,
                                 :language, :partial, :coverColor,
                                 topics: [])
  end
end
