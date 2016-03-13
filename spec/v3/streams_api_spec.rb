require 'rails_helper'


RSpec.describe "Streams api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed         = FactoryGirl.create(:feed)
      @subscribed   = FactoryGirl.create(:feed)
      Subscription.create! user: @user,
                           feed: @subscribed
      (0...ITEM_NUM).to_a.each { |n|
        UserEntry.create! user: @user,
                          entry: @feed.entries[n]
      }
      (0...ITEM_NUM).to_a.each { |n|
        Like.create! user: @user,
                     track: @subscribed.entries[0].tracks[n]
      }
    end

    it "gets a first per_page entries of a feed" do
      get "/api/v1/streams/#{@feed.escape.id}/contents",
          nil,
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(PER_PAGE)
      expect(result['continuation']).not_to be_nil
    end

    it "gets a specified page entries of a feed" do
      continuation = Api::V1::StreamsController::continuation(ITEM_NUM, PER_PAGE)
      get "/api/v1/streams/#{@feed.escape.id}/contents",
          {continuation: continuation},
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ENTRY_PER_FEED - PER_PAGE)
      expect(result['continuation']).to be_nil
    end

    it "gets entries of all subscirptions" do
      resource = CGI.escape "/user/#{@user.id}/category/global.all"
      get "/api/v1/streams/#{resource}/contents",
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
      resource = CGI.escape "/user/#{@user.id}/tag/global.saved"
      get "/api/v1/streams/#{resource}/contents",
          {},
          Authorization: "Bearer #{@token['access_token']}"
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ITEM_NUM)
      expect(result['continuation']).to be_nil
    end
  end

end
