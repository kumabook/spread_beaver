class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :destroy, :update]

  def index
    @feeds = Feed.all
    @subscriptions = Subscription.where(user_id: current_user.id)
  end

  def show
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new(feed_params)
    respond_to do |format|
      if @feed.save
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
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to feeds_path, notice: 'Feed was successfully updated.' }
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
    @feed = Feed.find(CGI.unescape params[:id])
  end

  def feed_params
    params.require(:feed).permit(:id, :title, :description, :website)
  end
end
