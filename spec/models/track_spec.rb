# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Track do
  let (:entries) { FactoryBot.create(:feed).entries }
  let (:track) { entries[0].tracks[0] }
  before do
  end

  it { expect(track.likers.count).to eq(track.likes_count) }
  it { expect(track.entries.count).to eq(track.entries_count) }

  context "when entry is deleted" do
    count = 0
    before do
      count = track.entries.count
      entries[0].destroy!
    end
    it { expect(track.entries.count).to eq(count - 1) }
  end

  describe "::topic" do
    let (:japanese_feed) { FactoryBot.create(:feed) }
    let (:english_feed) { FactoryBot.create(:feed) }
    let! (:japanese_topic) {
      Topic.create!(label: "japanese", description: "desc", feeds: [japanese_feed])
    }
    let! (:english_topic) {
      Topic.create!(label: "english", description: "desc", feeds: [english_feed])
    }

    TRACKS_PER_TOPIC = TRACK_PER_ENTRY * ENTRY_PER_FEED
    it { expect(Track.all.count).to eq(TRACKS_PER_TOPIC * 2) }
    it { expect(Track.topic(japanese_topic).count).to eq(TRACKS_PER_TOPIC) }
    it { expect(Track.topic(english_topic).count).to eq(TRACKS_PER_TOPIC) }
  end

  describe "#as_detail_json" do
    let! (:track)    { Track.create!(id: SecureRandom.uuid) }
    let! (:playlist) { Playlist.create!(id: SecureRandom.uuid) }
    let! (:pick)     {
      Pick.create!(enclosure_id:   track.id,
                   enclosure_type: Track.name,
                   container_id:   playlist.id,
                   container_type: Playlist.name)
    }
    let! (:user)     { FactoryBot.create(:default) }
    before do
      mock_up_pink_spider
      track.fetch_content
      Track.set_marks(user, [track])
    end
    it "should includes playlist marks" do
      json = track.as_detail_json
      expect(json["playlists"].count).to be > 0
      expect(json["playlists"][0]["entries_count"]).not_to be_nil
    end
  end
end
