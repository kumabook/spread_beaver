require 'rails_helper'

FEED_NUM = 2

RSpec.describe "Feeds api", :type => :request do
  before(:all) do
    setup()
    login()
    @feeds = (0...FEED_NUM).to_a.map { FactoryGirl.create(:feed) }
  end

  it "displays the feed list after successful login" do
    get "/api/v1/feeds", nil, Authorization: "Bearer #{@token['access_token']}"
    feeds = JSON.parse @response.body
    expect(feeds.count).to eq(FEED_NUM)
  end
end
