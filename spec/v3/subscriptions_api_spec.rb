require 'rails_helper'

RSpec.describe "Subscriptions api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed = FactoryGirl.create(:feed)
      @subscribed   = FactoryGirl.create(:feed)
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
          nil,
          Authorization: "Bearer #{@token['access_token']}"
      subscriptions = JSON.parse @response.body
      expect(subscriptions.count).to eq(1)
    end

    it "create a subscription" do
      post "/v3/subscriptions",
          @feed.as_json,
          Authorization: "Bearer #{@token['access_token']}"
      expect(@response.status).to eq(200)
      get "/v3/subscriptions",
          nil,
          Authorization: "Bearer #{@token['access_token']}"
      subscriptions = JSON.parse @response.body
      expect(subscriptions.count).to eq(2)
    end

    it "delete a subscription" do
      delete "/v3/subscriptions/#{@subscribed.escape.id}",
             nil,
             Authorization: "Bearer #{@token['access_token']}"
      expect(@response.status).to eq(200)
      get "/v3/subscriptions",
          nil,
          Authorization: "Bearer #{@token['access_token']}"
      subscriptions = JSON.parse @response.body
      expect(subscriptions.count).to eq(0)
    end

  end

end
