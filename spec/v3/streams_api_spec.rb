require 'rails_helper'


RSpec.describe "Streams api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed         = FactoryGirl.create(:feed)
      @subscribed   = FactoryGirl.create(:feed)
      @topic        = FactoryGirl.create(:topic)
      @feed.topics  = [@topic]
      Subscription.create! user: @user,
                           feed: @subscribed
      (0...ITEM_NUM).to_a.each { |n|
        UserEntry.create! user: @user,
                          entry: @feed.entries[n],
                          created_at: 1.days.ago
      }
      (0...ITEM_NUM).to_a.each { |n|
        Like.create! user: @user,
                     track: @subscribed.entries[0].tracks[n]
        Like.create! user: @user,
                     track: @feed.entries[0].tracks[n]
      }
    end

    it "gets a first per_page entries of a feed" do
      get "/v3/streams/#{@feed.escape.id}/contents",
          nil,
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(PER_PAGE)
      expect(result['continuation']).not_to be_nil
    end

    it "gets a specified page entries of a feed" do
      continuation = V3::StreamsController::continuation(ITEM_NUM, PER_PAGE)
      get "/v3/streams/#{@feed.escape.id}/contents",
          {continuation: continuation},
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ENTRY_PER_FEED - PER_PAGE)
      expect(result['continuation']).to be_nil
    end

    it "gets entries of all subscirptions" do
      resource = CGI.escape "user/#{@user.id}/category/global.all"
      get "/v3/streams/#{resource}/contents",
          {},
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(PER_PAGE)
      result['items'].each { |item|
        expect(item['feed_id']).to eq(@subscribed.id)
      }
      expect(result['continuation']).not_to be_nil
    end

    it "gets saved entries" do
      resource = CGI.escape "user/#{@user.id}/tag/global.saved"
      get "/v3/streams/#{resource}/contents",
          {},
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ITEM_NUM)
      expect(result['continuation']).to be_nil
    end

    it "gets latest entries" do
      resource = CGI.escape "tag/global.latest"
      get "/v3/streams/#{resource}/contents",
          {newer_than: 3.days.ago.to_time.to_i * 1000},
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(2)
      expect(result['continuation']).to be_nil
    end

    it "gets popular entries" do
      resource = CGI.escape "tag/global.popular"
      get "/v3/streams/#{resource}/contents", {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(2)
      expect(result['continuation']).to be_nil
    end

    it "gets entries of feeds that has a specified topic " do
      resource = CGI.escape @topic.id
      get "/v3/streams/#{resource}/contents", {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(PER_PAGE)
      result['items'].each { |item|
        expect(Entry.find(item['id']).feed).to eq(@feed)
      }
    end
  end
end
