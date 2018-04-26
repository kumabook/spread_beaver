# frozen_string_literal: true
require "securerandom"
require "active_support"
require "active_support/core_ext"

class PinkSpiderHelper
  PLAYLIST_TRACK_ID = SecureRandom.uuid
  def self.feed_hash(url)
    {
      id:           "feed/#{url}",
      url:          url,
      title:        "example feed",
      description:  "description",
      language:     "ja",
      velocity:     0,
      website:      "http://example.com/",
      state:        "alive",
      last_updated: "2017-03-16T05:37:02.807854+00:00",
      crawled:      "2017-03-16T05:37:02.807854+00:00",

      visual_url:  "http://visual.com",
      icon_url:    "http://visual.com",
      cover_url:   "http://visual.com",

      created_at:  "2017-03-16T05:37:02.807854+00:00",
      updated_at:  "2017-03-16T05:37:02.807854+00:00",
    }.with_indifferent_access
  end

  def self.entry_hash(url: "http://example.com")
    {
      id:          SecureRandom.uuid,
      url:         url,
      title:       "entry",
      description: "description",
      visual_url:  "http://visual.com",
      locale:       "ja",

      summary:     "",
      content:     "",
      author:      "",

      crawled:     "2017-03-16T05:37:02.807854+00:00",
      published:   "2017-03-16T05:37:02.807854+00:00",
      updated:     "2017-03-16T05:37:02.807854+00:00",
      fingerprint: "",
      origin_id:   url,
      alternate:   [{ href: url, type: "text/html" }],
      keywords:    [],
      enclosure:   [],

      created_at:  "2017-03-16T05:37:02.807854+00:00",
      updated_at:  "2017-03-16T05:37:02.807854+00:00",

      tracks:      [track_hash(shallow: true)],
      playlists:   [playlist_hash],
      albums:      [album_hash],
    }.with_indifferent_access
  end

  def self.track_hash(shallow: false)
    {
      id:           SecureRandom.uuid,
      provider:     "Spotify",
      identifier:   "012345",
      owner_id:     "user",
      owner_name:   nil,
      url:          "spotify:user",
      title:        "track",
      description:  "description",
      thumbnail_url: "http://example.com/thumb.jpg",
      artwork_url:  "http://example.com/artwork.jpg",
      audio_url:    "http://example.com/autio.mp3",
      duration:     60,
      published_at: "2017-03-16T05:37:02.807854+00:00",
      created_at:   "2017-03-16T05:37:02.807854+00:00",
      updated_at:   "2017-03-16T05:37:02.807854+00:00",
      state:        "alive",
      artists:      [],
      playlists:    shallow ? nil : [self.playlist_hash],
    }.with_indifferent_access
  end

  def self.album_hash
    {
      id:           SecureRandom.uuid,
      provider:     "Spotify",
      identifier:   "012345",
      owner_id:     "user",
      owner_name:   nil,
      url:          "spotify:album",
      title:        "album",
      description:  "description",
      thumbnail_url: "http://example.com/thumb.jpg",
      artwork_url:  "http://example.com/artwork.jpg",
      published_at: "2017-03-16T05:37:02.807854+00:00",
      created_at:   "2017-03-16T05:37:02.807854+00:00",
      updated_at:   "2017-03-16T05:37:02.807854+00:00",
      state:        "alive",
      artists:      [],
    }.with_indifferent_access
  end

  def self.playlist_hash
    {
      id:           SecureRandom.uuid,
      provider:     "Spotify",
      identifier:   "012345",
      owner_id:     "user",
      owner_name:   nil,
      url:          "spotify:album",
      title:        "album",
      description:  "description",
      thumbnail_url: "http://example.com/thumb.jpg",
      artwork_url:  "http://example.com/artwork.jpg",
      published_at: "2017-03-16T05:37:02.807854+00:00",
      created_at:   "2017-03-16T05:37:02.807854+00:00",
      updated_at:   "2017-03-16T05:37:02.807854+00:00",
      state:        "alive",
      tracks:    [{
                    playlist_id: SecureRandom.uuid,
                    track_id:    PLAYLIST_TRACK_ID,
                    track:       self.track_hash(shallow: true)
                  }],
    }.with_indifferent_access
  end
end
