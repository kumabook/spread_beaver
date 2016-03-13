require 'rails_helper'

RSpec.describe "Feeds api", :type => :request do
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
end
