class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :destroy]

  def index
    @title = 'Subscriptions'
    @subscriptions = Subscription.where(user_id: current_user.id).includes(:feed)
    @feeds = @subscriptions.map { |s| s.feed }
    render template: 'feeds/index'
  end

  def create
    @subscription = Subscription.new(subscription_params)
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to subscriptions_path, notice: 'Subscription was successfully created.' }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to subscriptions_path, notice: 'Subscription was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_subscription
    @subscription = Subscription.find(CGI.unescape params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:user_id, :feed_id)
  end

end
