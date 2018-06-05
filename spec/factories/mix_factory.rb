# coding: utf-8
# frozen_string_literal: true

FactoryBot.define do
  factory :mix_track, class: Track do
    sequence(:title) { |n| "mix track #{n}" }
    provider "Spotify"
    created_at 1.day.ago
  end

  factory :mix_playlist, class: Playlist do
    sequence(:title) { |n| "mix playlist #{n}" }
    provider "Spotify"
    created_at 1.day.ago
  end

  factory :mix_entry, class: Entry do
    sequence(:id) { |n| "entry#{n}" }
    sequence(:title) { |n| "entry #{n}" }
    content         '{"content":"content"}'
    summary         '{"content":"summary"}'
    author          nil
    alternate       "[]"
    origin          "{}"
    visual          '{"url": "http://test.jpg"}'
    engagement      9
    enclosure       "null"
    fingerprint     ""
    originId        ""
    crawled         DateTime.now
    recrawled       nil
    feed
  end

  factory :mix_feed, class: Feed do
    sequence(:id) { |n| "feed/http://test#{n}.com/rss" }
    sequence(:title) { |n| "Test feed #{n}" }
    description "description"
  end

  factory :mix, class: Topic do
    sequence(:label) { |n| "mix topic-#{n}" }
    after(:create) do |topic|
      feed              = create(:mix_feed)
      entry             = create(:mix_entry, feed: feed)
      today             = Time.now.beginning_of_day
      track             = create(:mix_track)
      playlist          = create(:mix_playlist)
      topic_mix_journal = Journal.create_topic_mix_journal(topic)
      issue             = topic.find_or_create_mix_issue(topic_mix_journal)
      issue.playlists << playlist
      topic.feeds << feed
      entry.tracks << track
      Pick.create!(enclosure_id:   track.id,
                   enclosure_type: Track.name,
                   container_id:   playlist.id,
                   container_type: Playlist.name,
                   created_at:     today,
                   updated_at:     today)
    end
  end
end
