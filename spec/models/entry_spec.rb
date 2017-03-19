# coding: utf-8
require 'rails_helper'
require 'feedlr_helper'

describe Entry do
  it "is created by feeldr entry" do
    feed_id = 'feed/http://test.com/rss'
    entry   = FeedlrHelper::entry(feed_id)
    feed    = Feed.first_or_create(id: feed_id)
    e       = Entry.first_or_create_by_feedlr(entry, feed)
    expect(e).not_to be_nil()
    expect(e.published).not_to be_nil()
    expect(e.crawled).not_to be_nil()
  end

  context "Entry.latest_entries" do
    feed_num = 5
    before(:each) do
      DatabaseCleaner.start
      feeds = (0..feed_num-1).map { |i| FactoryGirl.create(:feed) }
      feeds.each do |f|
        f.entries.each do |e|
          e.published = 2.days.ago
          e.save!
        end
      end
    end
    after(:each) do
      DatabaseCleaner.clean
    end
    it "showes first N entries since specified time" do
      top_of_last_3_days = Entry.latest_entries(entries_per_feed: 1, since: 3.days.ago)
      expect(top_of_last_3_days.count).to eq(feed_num)

      top_of_last_1_days = Entry.latest_entries(entries_per_feed: 1, since: 1.days.ago)
      expect(top_of_last_1_days.count).to eq(0)

      top3_of_last_3_days = Entry.latest_entries(entries_per_feed: 3, since: 3.days.ago)
      expect(top3_of_last_3_days.count).to eq(3 * feed_num)
      expect(top3_of_last_3_days[0].feed_id).not_to eq(top3_of_last_3_days[1].feed_id)
      expect(top3_of_last_3_days[0].feed_id).not_to eq(top3_of_last_3_days[2].feed_id)
      expect(top3_of_last_3_days[0].feed_id).to eq(top3_of_last_3_days[5].feed_id)
    end
  end

  context "Entry.popular_entries_within_period" do
    before(:each) do
      DatabaseCleaner.start
      user     = FactoryGirl.create(:member)
      feed     = FactoryGirl.create(:feed)
      old_feed = FactoryGirl.create(:feed)
      old_user = FactoryGirl.create(:member)
      (0...ITEM_NUM).to_a.each { |i|
        n = i + 1
        SavedEntry.create! user:       user,
                           entry:      feed.entries[n],
                           created_at: n.days.ago,
                           updated_at: n.days.ago
        SavedEntry.create! user:       old_user,
                           entry:      old_feed.entries[n],
                           created_at: n.months.ago,
                           updated_at: n.months.ago
      }
    end
    after(:each) do
      DatabaseCleaner.clean
    end

    it "showes popular entries within a certain time period" do
      all = Entry.popular_entries_within_period(from: 5.years.ago, to: Time.now)
      expect(all.count).to eq(ITEM_NUM * 2)

      latest_popular = Entry.popular_entries_within_period(from: 10.days.ago, to: Time.now)
      expect(latest_popular.count).to eq(ITEM_NUM)

      latest_popular = Entry.popular_entries_within_period(from: 1.years.ago, to: 20.days.ago)
      expect(latest_popular.count).to eq(ITEM_NUM)
    end
  end
end
