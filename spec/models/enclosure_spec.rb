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
  describe "::create_items_of" do
    before do
      Track.create_items_of(   entry, playlistified_entry.tracks)
      Album.create_items_of(   entry, playlistified_entry.albums)
      Playlist.create_items_of(entry, playlistified_entry.playlists)
    end
    it { expect(Track.count).to eq(1) }
    it { expect(Album.count).to eq(1) }
    it { expect(Playlist.count).to eq(1) }
  end

  describe "::most_featured_items_within_period" do
    tracks = []
    before do
      entries = 5.times.map { FactoryGirl.create(:normal_entry, feed: feed) }
      tracks = 5.times.map do |n|
        t = Track.create!
        n.times do |i|
          EntryEnclosure.create!(entry:          entries[i],
                                 enclosure_id:   t.id,
                                 enclosure_type: Track.name,
                                 created_at:     n.days.ago,
                                 updated_at:     n.days.ago)
        end
        t
      end
    end

    it "should return most featured entries during specified period" do
      old_items = Track.most_featured_items_within_period(period:   10.days.ago..Time.now,
                                                          page:     1,
                                                          per_page: 10)
      expect(old_items.count).to eq(4)
      expect(old_items[0]).to eq(tracks[4])
      expect(old_items[1]).to eq(tracks[3])
      expect(old_items[2]).to eq(tracks[2])
      expect(old_items[3]).to eq(tracks[1])

      items     = Track.most_featured_items_within_period(period:   3.days.ago..Time.now,
                                                          page:     1,
                                                          per_page: 10)
      expect(items.count).to eq(2)
      expect(items[0]).to eq(tracks[2])
      expect(items[1]).to eq(tracks[1])
    end
  end
end
