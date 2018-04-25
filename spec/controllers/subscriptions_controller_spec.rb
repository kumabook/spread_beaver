# frozen_string_literal: true
require "rails_helper"

describe SubscriptionsController, type: :controller do
  let! (:user        ) { FactoryBot.create (:admin )}
  let! (:feed        ) { Feed.create!(id: "feed/http://test.com/rss"  , title: "feed") }
  let! (:feed2       ) { Feed.create!(id: "feed/http://test2.com/rss" , title: "feed") }
  let! (:subscription) { Subscription.create!(user: user, feed: feed) }
  let! (:category    ) {
    Category.create!(user: user, label: "category", subscriptions: [subscription])
  }

  before(:each) do
    login_user user
  end

  describe "#index" do
    context "without category" do
      before { get :index }
      it { expect(assigns(:subscriptions)).to eq([subscription])  }
      it { expect(assigns(:feeds)).to eq([feed])  }
      it { expect(response).to render_template("index") }
    end
    context "with category" do
      before { get :index, params: { category_id: category.id} }
      it { expect(assigns(:subscriptions)).to eq([subscription])  }
      it { expect(assigns(:feeds)).to eq([feed])  }
      it { expect(response).to render_template("index") }
    end
  end

  describe "#create" do
    context "when succeeds in creating" do
      before {
        post :create, params: {
               subscription: {
                 user_id: user.id,
                 feed_id: feed2.id,
                 categories: [],
               }
             }
      }
      it { expect(response).to redirect_to subscriptions_url }
      it { expect(Subscription.find_by(user: user, feed: feed)).not_to be_nil }
    end
    context "when fails to create" do
      before {
        allow_any_instance_of(Subscription).to receive(:save).and_return(false)
        post :create, params: { subscription: { user_id: user.id, feed_id: feed.id } }
      }
      it { expect(response).to redirect_to subscriptions_url }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe "#edit" do
    before { get :edit, params: { id: subscription.id }}
    it { expect(response).to render_template("edit") }
  end

  describe "#update" do
    categories = []
    params = {}
    before {
      categories = [category.id]
      params = {
        id: subscription.id,
        subscription: {
          user_id: user.id,
          feed_id: feed.id,
          categories: categories,
        }
      }
    }
    context "when succeeds in saving" do
      before { post :update, params: params }
      it { expect(response).to redirect_to subscriptions_url }
      it { expect(Subscription.find(subscription.id)).not_to be_nil() }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Subscription).to receive(:save).and_return(false)
        post :update, params: params
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "#destroy" do
    context "when succeeds in saving" do
      before {
        delete :destroy, params: { id: subscription.id }
      }
      it { expect(response).to redirect_to subscriptions_url }
      it { expect(Subscription.find_by(id: subscription.id)).to be_nil }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Subscription).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: subscription.id }
      }
      it { expect(response).to redirect_to subscriptions_url }
    end
  end

end
