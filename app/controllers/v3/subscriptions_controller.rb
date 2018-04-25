# frozen_string_literal: true
class V3::SubscriptionsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_feed, only: [:create, :destroy]
  before_action :set_unescaped_feed, only: [:destroy]


  def index
    @subscriptions = Subscription.where(user: current_resource_owner).includes(:feed)
    render json: @subscriptions.map {|s| s.feed }.to_json, status: 200
  end

  def create
    @subscription = Subscription.new(user: current_resource_owner,
                                     feed: @feed)
    if @subscription.save
      render json: {}, status: 200
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription = Subscription.find_by(user: current_resource_owner,
                                         feed: @feed)
    if @subscription.nil?
      render json: {}, status: :not_found
    elsif @subscription.destroy
      render json: {}, status: 200
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  def set_feed
    @feed = Feed.includes(:topics).find_by(id: params[:id])
  end

  def set_unescaped_feed
    @feed = Feed.includes(:topics).find_by(id: CGI.unescape(params[:id]))
  end

end
