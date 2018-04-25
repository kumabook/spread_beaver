# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Subscriptions api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed = FactoryBot.create(:feed)
      @subscribed   = FactoryBot.create(:feed)
      Subscription.create! user: @user,
                           feed: @subscribed
    end

    before(:each) do
      DatabaseCleaner.start
    end

    after(:each) do
      DatabaseCleaner.clean
    end

    it "gets subscriptions" do
      get "/v3/subscriptions",
          headers: headers_for_login_user_api
      subscriptions = JSON.parse @response.body
      expect(subscriptions.count).to eq(1)
    end

    it "create a subscription" do
      post "/v3/subscriptions",
           params: @feed.as_json,
           headers: headers_for_login_user
      expect(@response.status).to eq(200)
      get "/v3/subscriptions",
          headers: headers_for_login_user_api
      subscriptions = JSON.parse @response.body
      expect(subscriptions.count).to eq(2)
    end

    it "fail to create exist subscription" do
      post "/v3/subscriptions",
           params: @subscribed.as_json,
           headers: headers_for_login_user
      expect(@response.status).to eq(409)
    end

    it "delete a subscription" do
      delete "/v3/subscriptions/#{@subscribed.escape.id}",
             headers: headers_for_login_user_api
      expect(@response.status).to eq(200)
      get "/v3/subscriptions",
          headers: headers_for_login_user_api
      subscriptions = JSON.parse @response.body
      expect(subscriptions.count).to eq(0)
    end

    it "fail to delete unexist subscription" do
      delete "/v3/subscriptions/#{@feed.escape.id}",
             headers: headers_for_login_user_api
      expect(@response.status).to eq(404)
    end
  end
end
