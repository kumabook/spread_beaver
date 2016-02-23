require 'rails_helper'

RSpec.describe "Likes api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed = FactoryGirl.create(:feed)
      (0...2).to_a.each { |n|
        Like.create! user: @user,
                     track: @feed.entries[0].tracks[n]
      }
    end

    it "gets a first per_page liked tracks of a user" do
      get "/api/v1/likes",
          nil,
          Authorization: "Bearer #{@token['access_token']}"
      likes = JSON.parse @response.body
      expect(likes.count).to eq(2)
    end
  end
end
