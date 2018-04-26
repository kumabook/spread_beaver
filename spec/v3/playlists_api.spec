# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Playlists api", type: :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryBot.create(:feed) }
    @like = LikedEnclosure.create!(user:           @user,
                                   enclosure:      @feeds[0].entries[0].playlists[0],
                                   enclosure_type: Playlist.name)
    @track = Track.create!(id: PinkSpiderHelper::PLAYLIST_TRACK_ID)
    @track.entries = [@feeds[0].entries[0]]
    @pick = Pick.create!(enclosure_id:   @track.id,
                         enclosure_type: Track.name,
                         container_id:   @feeds[0].entries[0].playlists[0].id,
                         container_type: Playlist.name)
  end

  it "shows a playlist by id" do
    id = @feeds[0].entries[0].playlists[0].id
    get "/v3/playlists/#{id}", headers: headers_for_login_user_api
    playlist = JSON.parse @response.body
    expect(playlist).not_to be_nil()
    expect(playlist["id"]).to eq(id)
    expect(playlist["entries"]).not_to be_nil()
    expect(playlist["likesCount"]).to eq(1)
    expect(playlist["entriesCount"]).not_to be_nil()
    expect(playlist["tracks"].count).to be > 0
    expect(playlist["tracks"][0]).not_to be_nil
    expect(playlist["tracks"][0]["track"]["entriesCount"]).not_to be_nil
    expect(playlist["tracks"][0]["track"]["entries"].count).not_to be_nil
    expect(playlist["tracks"][0]["track"]["entries"][0]).not_to be_nil
  end

  it "shows playlist list by id list" do
    ids = @feeds[0].entries[0].playlists.map(&:id)
    post "/v3/playlists/.mget",
         params: ids.to_json,
         headers: headers_for_login_user_api
    playlists = JSON.parse @response.body
    expect(playlists).not_to be_nil()
    expect(playlists.count).to eq(ids.count)
    playlists.each_with_index { |t, _i|
      expect(ids).to include(t["id"])
    }
  end
end
