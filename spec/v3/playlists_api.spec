require 'rails_helper'

RSpec.describe "Playlists api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryGirl.create(:feed) }
    @like = EnclosureLike.create!(enclosure: @feeds[0].entries[0].playlists[0],
                                  user: @user)
  end

  it "shows a playlist by id" do
    id = @feeds[0].entries[0].playlists[0].id
    get "/v3/playlists/#{id}", headers: headers_for_login_user_api
    playlist = JSON.parse @response.body
    expect(playlist).not_to be_nil()
    expect(playlist['id']).to eq(id)
    expect(playlist['entries']).not_to be_nil()
    expect(playlist['likers']).not_to be_nil()
    expect(playlist['likesCount']).not_to be_nil()
    expect(playlist['entriesCount']).not_to be_nil()
  end

  it "shows playlist list by id list" do
    ids = @feeds[0].entries[0].playlists.map { |t| t.id }
    post "/v3/playlists/.mget",
         params: ids.to_json,
         headers: headers_for_login_user_api
    playlists = JSON.parse @response.body
    expect(playlists).not_to be_nil()
    expect(playlists.count).to eq(ids.count)
    playlists.each_with_index {|t, i|
      expect(ids).to include(t['id'])
    }
  end
end
