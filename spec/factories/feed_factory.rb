# coding: utf-8

TRACK_PER_ENTRY = 5
ENTRY_PER_FEED  = 35

FactoryGirl.define do

  factory :entry_track, class: EntryTrack do
    entry_id 'entry'
    track_id 1
  end

  factory :track, class: Track do
    sequence(:identifier) { |n| "track#{n}" }
    sequence(:title) { |n| "track #{n}" }
    provider "YouTube"
  end

  factory :entry, class: Entry do
    sequence(:id) { |n| "entry#{n}" }
    sequence(:title) { |n| "entry #{n}" }
    content         "{\"content\":\"\"}"
    summary         "null"
    author          nil
    alternate       "[]"
    origin          "{}"
    keywords        "[]"
    visual          "{}"
    tags            "null"
    categories      "null"
    unread          true
    engagement      9
    actionTimestamp nil
    enclosure       "null"
    fingerprint     ""
    originId        ""
    sid             nil
    crawled         nil
    recrawled       nil
    published       nil
    updated         nil
    feed
    after(:create) do |e|
      TRACK_PER_ENTRY.times {
        t = create(:track)
        entry_track = create(:entry_track, entry: e, track: t)
      }
    end
  end

  factory :feed, class: Feed do
    sequence(:id) { |n| "feed/http://test#{n}.com/rss" }
    sequence(:title) { |n| "Test feed #{n}" }
    description  "description"
    website      "http://test.com"
    visualUrl    "http://test.com"
    coverUrl     "http://test.com"
    iconUrl      "http://test.com"
    language     "ja"
    partial      "t"
    coverColor   "000000"
    contentType  "article"
    subscribers  100
    velocity     10.0
    topics       "[\"music\", \"音楽\"]"
    after(:create) do |f|
      ENTRY_PER_FEED.times { create(:entry, feed: f) }
    end
  end
end
