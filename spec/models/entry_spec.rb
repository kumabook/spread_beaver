# coding: utf-8
# frozen_string_literal: true
require "rails_helper"
require "feedlr_helper"

describe Entry do
  it "is created by feeldr entry" do
    feed_id = "feed/http://test.com/rss"
    entry   = FeedlrHelper::entry(feed_id)
    feed    = Feed.first_or_create(id: feed_id)
    e       = Entry.first_or_create_by_feedlr(entry, feed)
    expect(e).not_to be_nil()
    expect(e.published).not_to be_nil()
    expect(e.crawled).not_to be_nil()
  end

  describe "::set_count_of_enclosures" do
    let (:feed) { FactoryBot.create(:feed) }
    before do
      Entry::set_count_of_enclosures(feed.entries)
    end
    it {
      expect(feed.entries[0].count_of            ).not_to be_nil
      expect(feed.entries[0].count_of[:tracks]   ).to eq(TRACK_PER_ENTRY)
      expect(feed.entries[0].count_of[:albums]   ).to eq(ALBUM_PER_ENTRY)
      expect(feed.entries[0].count_of[:playlists]).to eq(PLAYLIST_PER_ENTRY)
    }
  end

  describe "::latest_items" do
    feed_num = 5
    before(:each) do
      feeds = (0..feed_num-1).map { |i| FactoryBot.create(:feed) }
      feeds.each do |f|
        f.entries.each do |e|
          e.published = 2.days.ago
          e.save!
        end
      end
    end
    it "showes first N entries since specified time" do
      top_of_last_3_days = Entry.latest_items(entries_per_feed: 1, since: 3.days.ago)
      expect(top_of_last_3_days.count).to eq(feed_num)

      top_of_last_1_days = Entry.latest_items(entries_per_feed: 1, since: 1.day.ago)
      expect(top_of_last_1_days.count).to eq(0)

      top3_of_last_3_days = Entry.latest_items(entries_per_feed: 3, since: 3.days.ago)
      expect(top3_of_last_3_days.count).to eq(3 * feed_num)
      expect(top3_of_last_3_days[0].feed_id).not_to eq(top3_of_last_3_days[1].feed_id)
      expect(top3_of_last_3_days[0].feed_id).not_to eq(top3_of_last_3_days[2].feed_id)
      expect(top3_of_last_3_days[0].feed_id).to eq(top3_of_last_3_days[5].feed_id)
    end
  end

  describe "::popular_items" do
    before(:each) do
      user     = FactoryBot.create(:member)
      feed     = FactoryBot.create(:feed)
      old_feed = FactoryBot.create(:feed)
      old_user = FactoryBot.create(:member)
      (0...ITEM_NUM).to_a.each { |i|
        n = i + 1
        LikedEntry.create! user:       user,
                           entry:      feed.entries[n],
                           created_at: n.days.ago,
                           updated_at: n.days.ago
        LikedEntry.create! user:       old_user,
                           entry:      old_feed.entries[n],
                           created_at: n.months.ago,
                           updated_at: n.months.ago
      }
    end

    it "showes popular entries within a certain time period" do
      all = Entry.popular_items(query: Mix::Query.new(5.years.ago..Time.now))
      expect(all.count).to eq(ITEM_NUM * 2)

      latest_popular = Entry.popular_items(query: Mix::Query.new(10.days.ago..Time.now))
      expect(latest_popular.count).to eq(ITEM_NUM)

      latest_popular = Entry.popular_items(query: Mix::Query.new(1.year.ago..20.days.ago))
      expect(latest_popular.count).to eq(ITEM_NUM)
    end
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

    it {
      expect(Entry.all.count).to eq(ENTRY_PER_FEED * 2)
      expect(Entry.topic(japanese_topic).count).to eq(ENTRY_PER_FEED)
      expect(Entry.topic(english_topic).count).to eq(ENTRY_PER_FEED)
    }
  end

  describe "#crawl" do
    let (:feed) { FactoryBot.create(:feed) }
    let (:entry) { feed.entries[0] }
    before { mock_up_pink_spider }
    it {
      expect(entry.crawl()[:tracks].count).to be > 0
      expect(entry.crawl()[:playlists].count).to be > 0
      expect(entry.crawl()[:albums].count).to be > 0
    }
  end
end
