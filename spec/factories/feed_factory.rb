# coding: utf-8

FactoryGirl.define do
  factory :entry_track, class: EntryEnclosure do
    entry_id       nil
    enclosure_id   nil
    enclosure_type Track.name
  end
  factory :entry_album, class: EntryEnclosure do
    entry_id       nil
    enclosure_id   nil
    enclosure_type Album.name
  end
  factory :entry_playlist, class: EntryEnclosure do
    entry_id       nil
    enclosure_id   nil
    enclosure_type Playlist.name
  end

  factory :track, class: Track do
    sequence(:created_at) { |n|
      if n % TRACK_PER_ENTRY == 0
        1.days.ago
      else
        5.days.ago
      end
    }
  end

  factory :album, class: Album do
    sequence(:created_at) { |n|
      if n % ALBUM_PER_ENTRY == 0
        1.days.ago
      else
        5.days.ago
      end
    }
  end

  factory :playlist, class: Playlist do
    sequence(:created_at) { |n|
      if n % PLAYLIST_PER_ENTRY == 0
        1.days.ago
      else
        5.days.ago
      end
    }
  end

  factory :entry, class: Entry do
    sequence(:id) { |n| "entry#{n}" }
    sequence(:title) { |n| "entry #{n}" }
    content         "{\"content\":\"\"}"
    summary         "null"
    author          nil
    alternate       "[]"
    origin          "{}"
    visual          '{"url": "http://test.jpg"}'
    categories      "null"
    unread          true
    engagement      9
    actionTimestamp nil
    enclosure       "null"
    fingerprint     ""
    originId        ""
    sid             nil
    crawled         DateTime.now
    recrawled       nil
    sequence(:published) do |n|
      if n % ENTRY_PER_FEED == 0
        1.days.ago
      else
        5.days.ago
      end
    end
    updated         nil
    feed
    after(:create) do |e|
      TRACK_PER_ENTRY.times {
        t = create(:track)
        create(:entry_track, entry_id: e.id, enclosure_id: t.id)
      }
      ALBUM_PER_ENTRY.times {
        t = create(:album)
        create(:entry_album, entry_id: e.id, enclosure_id: t.id)
      }
      PLAYLIST_PER_ENTRY.times {
        p = create(:playlist)
        create(:entry_playlist, entry_id: e.id, enclosure_id: p.id)
      }
    end
  end

  factory :feed, class: Feed do
    sequence(:id) { |n| "feed/http://test#{n}.com/rss" }
    sequence(:title) { |n| "Test feed #{n}" }
    description  "description"
    sequence(:website)      { |n| "http://test#{n}.com" }
    sequence(:visualUrl)    { |n| "http://test#{n}.com/visual" }
    sequence(:coverUrl)     { |n| "http://test#{n}.com/cover" }
    sequence(:iconUrl)      { |n| "http://test#{n}.com/icon" }
    language     "ja"
    partial      "t"
    coverColor   "000000"
    contentType  "article"
    subscribers  100
    velocity     10.0
    after(:create) do |f|
      ENTRY_PER_FEED.times { create(:entry, feed: f) }
    end
  end

  factory :keyword, class: Keyword do
    sequence(:label) { |n| "keyword-#{n}" }
  end

  factory :topic, class: Topic do
    sequence(:label) { |n| "topic-#{n}" }
  end
end
