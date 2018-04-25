# frozen_string_literal: true
class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  before_action :set_category, only: [:index]

  def index
    if @category.present?
      @subscriptions = @category.subscriptions
    else
      @subscriptions = Subscription.where(user_id: current_user.id).includes(:feed)
    end
    @feeds = @subscriptions.map { |s| s.feed }
  end

  def create
    @subscription = Subscription.new(create_subscription_params)
    respond_as_create(@subscription)
  end

  def edit
  end

  def update
    categories = Category.find((subscription_params[:categories] || []).select { |c| !c.blank? })
    @subscription.update_attributes(subscription_params.merge({categories: categories}))
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to subscriptions_path, notice: 'Subscription was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    respond_as_destroy(@subscription)
  end

  private

  def set_subscription
    @subscription = Subscription.find(CGI.unescape params[:id])
  end

  def set_category
    @category = Category.find_by(id: params[:category_id])
  end

  def create_subscription_params
    params.require(:subscription).permit(:user_id, :feed_id, acategories: [])
  end

  def subscription_params
    params.permit(:subscription).permit(:user_id, :feed_id, categories: [])
  end

end
