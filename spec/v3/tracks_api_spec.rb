require 'rails_helper'

RSpec.describe "Tracks api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryGirl.create(:feed) }
    @like = Like.create!(track: @feeds[0].entries[0].tracks[0],
                          user: @user)
  end

  it "shows a track by id" do
    id = @feeds[0].entries[0].tracks[0].id
    get "/v3/tracks/#{id}", headers: { Authorization: "Bearer #{@token['access_token']}" }
    track = JSON.parse @response.body
    expect(track).not_to be_nil()
    expect(track['id']).to eq(id)
    expect(track['entries']).not_to be_nil()
    expect(track['likers']).not_to be_nil()
    expect(track['likesCount']).not_to be_nil()
    expect(track['entriesCount']).not_to be_nil()
  end

  it "shows track list by id list" do
    ids = @feeds[0].entries[0].tracks.map { |t| t.id }
    post "/v3/tracks/.mget",
         params: ids.to_json,
         headers: {
           Authorization: "Bearer #{@token['access_token']}",
           CONTENT_TYPE: 'application/json',
           Accept: 'application/json'
         }
    tracks = JSON.parse @response.body
    expect(tracks).not_to be_nil()
    expect(tracks.count).to eq(ids.count)
    tracks.each_with_index {|t, i|
      expect(ids).to include(t['id'])
    }
  end
end
