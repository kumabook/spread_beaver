require 'rails_helper'

RSpec.describe "Feeds api", :type => :request do
  before(:all) do
    setup()
    login()
    @feeds = (0...10).to_a.map { FactoryGirl.create(:feed) }
  end

  it "displays the feed list after successful login" do
    get "/api/v1/feeds", nil, Authorization: "Bearer #{@token['access_token']}"
    feeds = JSON.parse @response.body
    expect(feeds.count).to eq(10)
  end
end
