# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Tracks api", type: :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryBot.create(:feed) }
    @like = LikedEnclosure.create!(enclosure: @feeds[0].entries[0].tracks[0],
                                   user: @user)
    @feeds[0].entries[1].tracks << @feeds[0].entries[0].tracks[0]
    @feeds[0].entries[0].update!(published: 1.days.ago)
    @feeds[0].entries[1].update!(published: 2.days.ago)
    @pick = Pick.create!(enclosure_id:   @feeds[0].entries[0].tracks[0].id,
                         enclosure_type: Track.name,
                         container_id:   Playlist.first.id,
                         container_type: Playlist.name)
  end

  it "shows a track by id" do
    id = @feeds[0].entries[0].tracks[0].id
    get "/v3/tracks/#{id}", headers: headers_for_login_user_api
    track = JSON.parse @response.body
    es = track["entries"]
    expect(track).not_to be_nil()
    expect(track["id"]).to eq(id)
    expect(track["entries"]).not_to be_nil()
    expect(track["entries"].count).to be(2)
    expect(track["entries"][0]["summary"]).to be_nil
    expect(es[0]["published"] > es[1]["published"]).to be_truthy
    expect(track["likesCount"]).to eq(1)
    expect(track["entriesCount"]).not_to be_nil()
    expect(track["playlists"].count).to be > 0
    expect(track["playlists"][0]).not_to be_nil
    expect(track["playlists"][0]["entriesCount"]).not_to be_nil
    expect(track["playlists"][0]["entries"].count).not_to be_nil
    expect(track["playlists"][0]["entries"][0]).not_to be_nil
  end

  it "shows track list by id list" do
    tracks = @feeds[0].entries[0].tracks
    ids = tracks.map(&:id)
    ids.push "unknown_track_id"
    post "/v3/tracks/.mget",
         params: ids.to_json,
         headers: headers_for_login_user_api
    items = JSON.parse @response.body
    expect(items).not_to be_nil()
    expect(items.count).to eq(tracks.count)
    expect(items[0]["entries"][0]["summary"]).to be_nil
    items.each_with_index { |t, i|
      expect(ids).to include(t["id"])
    }
  end
end
