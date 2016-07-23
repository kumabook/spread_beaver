require 'rails_helper'

RSpec.describe "Feeds api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryGirl.create(:feed) }
  end

  it "searches feeds after successful login" do
    count = Feed.count
    get "/v3/search/feeds", {
          query: '',
          count: count - 1,
          locale: 'ja'
        }, Authorization: "Bearer #{@token['access_token']}"
    result = JSON.parse @response.body
    expect(result['results'].count).to eq(count - 1)
    expect(result['hint']).to eq('music')
  end

  it "shows a feed by id" do
    id = @feeds[0].escape.id
    get "/v3/feeds/#{id}", nil, Authorization: "Bearer #{@token['access_token']}"
    feed = JSON.parse @response.body
    expect(feed).not_to be_nil()
    expect(feed['id']).to eq(@feeds[0].id)
  end

  it "shows feeds list by id list" do
    ids = @feeds.map { |t| t.id }
    post "/v3/feeds/.mget", ids.to_json,
         Authorization: "Bearer #{@token['access_token']}",
          CONTENT_TYPE: 'application/json',
                Accept: 'application/json'
    feeds = JSON.parse @response.body
    expect(feeds).not_to be_nil()
    feeds.each_with_index {|f, i|
      expect(f['id']).to eq(ids[i])
    }
  end
end
