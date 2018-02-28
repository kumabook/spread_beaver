require 'rails_helper'
require 'pink_spider_helper'

describe Enclosure do
  let (:feeds) {
    5.times.map {|i| Feed.create!(id: "feed/http://test#{i}.com/rss" , title: "feed#{i}") }
  }

  let (:entry) { FactoryBot.create(:normal_entry, feed: feeds[0] )}
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

  describe "::most_featured_items" do
    tracks = []
    before do
      feeds.each {|feed|
        feed.entries = 3.times.map { FactoryBot.create(:normal_entry, feed: feed) }
      }
      tracks = 5.times.map do |n|
        t = Track.create!
        (n+1).times do |i|
          EntryEnclosure.create!(entry:          feeds[i].entries[0],
                                 enclosure_id:   t.id,
                                 enclosure_type: Track.name,
                                 created_at:     n.days.ago,
                                 updated_at:     n.days.ago)
        end
        t
      end
    end

    it "should return most featured entries during specified period" do
      old_items = Track.most_featured_items(period:   10.days.ago..Time.now,
                                            page:     1,
                                            per_page: 10)
      expect(old_items.count).to eq(5)
      expect(old_items[0]).to eq(tracks[4])
      expect(old_items[1]).to eq(tracks[3])
      expect(old_items[2]).to eq(tracks[2])
      expect(old_items[3]).to eq(tracks[1])
      expect(old_items[4]).to eq(tracks[0])

      items     = Track.most_featured_items(period:   3.days.ago..Time.now,
                                            page:     1,
                                            per_page: 10)
      expect(items.count).to eq(3)
      expect(items[0]).to eq(tracks[2])
      expect(items[1]).to eq(tracks[1])
      expect(items[2]).to eq(tracks[0])
    end

    context "multiple entries about feed" do
      before do
        (1..2).each {|i|
          EntryEnclosure.create!(entry:          feeds[1].entries[i],
                                 enclosure_id:   tracks[1].id,
                                 enclosure_type: Track.name,
                                 created_at:     1.days.ago,
                                 updated_at:     1.days.ago)
        }
      end
      it "should calcurated by feed count (not entry count" do
        old_items = Track.most_featured_items(period:   10.days.ago..Time.now,
                                              page:     1,
                                              per_page: 10)
        expect(old_items.count).to eq(5)
        expect(old_items[0].id).to eq(tracks[4].id)
        expect(old_items[1].id).to eq(tracks[3].id)
        expect(old_items[2].id).to eq(tracks[2].id)
        expect(old_items[3].id).to eq(tracks[1].id)
        expect(old_items[4].id).to eq(tracks[0].id)
      end
    end
  end
end
