# coding: utf-8
require 'rails_helper'

describe Entry do
  it "is created by feeldr entry" do

    alternate         = Feedlr::Base.new()
    alternate.href     = "http://test.com/1"
    alternate.type     ="text/html"

    content            = Feedlr::Base.new()
    content.content    = "content"
    content.direction  = "ltr"
    origin             = Feedlr::Base.new()
    origin.htmlUrl     = "http://test.com"
    origin.streamId    = "feed/http://test.com/rss"
    origin.title       = "feed"
    visual             = Feedlr::Base.new()
    visual.contentType ="image/jpeg"
    visual.height      = 504
    visual.width       = 500
    visual.processor   = "feedly-nikon-v3.1"
    visual.url         = "http://test.com/1/img.jpg"

    entry                = Feedlr::Base.new()
    entry.alternate      = alternate
    entry.content        = content
    entry.crawled        = 1458303643798
    entry.engagement     = 143
    entry.engagementRate = 11.0
    entry.fingerprint    = "38c6513d"
    entry.id             = "12345"
    entry.keywords       = ["SERIES"]
    entry.origin         =  origin
    entry.originId       = "http://test.com/1"
    entry.published      = 1458303643798
    entry.title          = "title"
    entry.unread         = true
    entry.visual         = visual

    f = Feed.first_or_create(id: 'feed/http://test.com/rss')
    e = Entry.first_or_create_by_feedlr(entry, f)
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
    feed_num = 5
    before(:each) do
      DatabaseCleaner.start
      user     = FactoryGirl.create(:member)
      feed     = FactoryGirl.create(:feed)
      old_feed = FactoryGirl.create(:feed)
      old_user = FactoryGirl.create(:member)
      (0...ITEM_NUM).to_a.each { |i|
        n = i + 1
        UserEntry.create! user:       user,
                          entry:      feed.entries[n],
                          created_at: n.days.ago,
                          updated_at: n.days.ago
        UserEntry.create! user:       old_user,
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
