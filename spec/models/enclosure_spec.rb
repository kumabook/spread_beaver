require 'rails_helper'
require 'pink_spider_helper'

describe Enclosure do
  let (:feed  ) { Feed.create!(id: "feed/http://test.com/rss" , title: "feed") }
  let (:entry) { FactoryGirl.create(:normal_entry, feed: feed )}
  let (:playlistified_entry) {
    e = PinkSpiderHelper::entry_hash
    PlaylistifiedEntry.new(e[:id],
                           e[:url],
                           e[:title],
                           e[:description],
                           e[:visual_url],
                           e[:locale],
                           e[:tracks],
                           e[:playlists],
                           e[:albums],
                           entry)
  }
  describe ".create_items_of" do
    before do
      Track.create_items_of(   entry, playlistified_entry.tracks)
      Album.create_items_of(   entry, playlistified_entry.albums)
      Playlist.create_items_of(entry, playlistified_entry.playlists)
    end
    it { expect(Track.count).to eq(1) }
    it { expect(Album.count).to eq(1) }
    it { expect(Playlist.count).to eq(1) }
  end
end
