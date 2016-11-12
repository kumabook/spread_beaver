require 'rails_helper'


RSpec.describe "Track Stream api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed    = FactoryGirl.create(:feed)
      (0...ITEM_NUM).to_a.each { |n|
        Like.create! user: @user,
                     track: @feed.entries[0].tracks[n],
                     created_at: 1.days.ago
      }
    end


    it "gets latest tracks with pagination" do
      resource = CGI.escape "playlist/global.latest"
      get "/v3/streams/#{resource}/tracks/contents",
          params: { newer_than: 3.days.ago.to_time.to_i * 1000 },
          headers: { Authorization: "Bearer #{@token['access_token']}" }
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(PER_PAGE)
      expect(result['continuation']).not_to be_nil

      get "/v3/streams/#{resource}/tracks/contents",
          params: { continuation: result['continuation'] },
          headers: { Authorization: "Bearer #{@token['access_token']}" }
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(Entry.all.count - PER_PAGE)
      expect(result['continuation']).to be_nil
    end

    it "gets popular tracks" do
      resource = CGI.escape "playlist/global.popular"
      get "/v3/streams/#{resource}/tracks/contents",
          params: {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          headers: { Authorization: "Bearer #{@token['access_token']}" }
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(2)
      expect(result['continuation']).to be_nil
    end

  end
end
