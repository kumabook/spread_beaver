# frozen_string_literal: true

require "securerandom"
require "active_support"
require "active_support/core_ext"

class RSpotifyHelper
  def self.track_hash(id, shallow: false)
    {
      available_markets: ["JP", "US"],
      disc_number: 1,
      duration_ms: 100,
      explicit: false,
      external_ids: { isrc: "GBUM71802820" },
      uri: "spotify:track:5Q2LXkoqv8REmtHuXhbjJI",
      name: "Don't Miss It",
      popularity: 61,
      preview_url: nil,
      track_number: 11,
      played_at: nil,
      context_type: nil,
      is_playable: nil,
      album: album_hash(SecureRandom.uuid, shallow: true),
      artists: [artist_hash(SecureRandom.uuid, shallow: true)],
      linked_from: nil,
      external_urls: { spotify: "https://open.spotify.com/track/xxxx" },
      href: "https://api.spotify.com/v1/tracks/xxxx",
      id: id,
      type: "track",
    }.with_indifferent_access
  end

  def self.album_hash(id, shallow: false)
    {
        album_type: "album",
        available_markets: ["JP", "US"],
        copyrights: nil,
        external_ids: nil,
        genres: [],
        images: [
          { height: 640, url: "https://i.scdn.co/image/xxxx", width: 640 },
          { height: 300, url: "https://i.scdn.co/image/xxxx", width: 300 },
          { height: 64, url: "https://i.scdn.co/image/xxxx", width: 64 }
        ],
        name: "Assume Form",
        popularity: nil,
        release_date: "2019-01-18",
        release_date_precision: "day",
        artists: [artist_hash(SecureRandom.uuid, shallow: true)],
        tracks_cache: nil,
        total_tracks: nil,
        external_urls: { spotify: "https://open.spotify.com/album/xxxx" },
        href: "https://api.spotify.com/v1/albums/xxxx",
        id: id,
        type: "album",
        uri: "spotify:album:xxxx"
    }.with_indifferent_access
  end

  def self.artist_hash(id, shallow: false)
    {
      followers: { href: nil, total: 0 },
      genres: ["garage rock", "indie rock", "modern rock", "permanent wave", "rock", "sheffield indie"],
      images: [
        { height: 640, url: "https://i.scdn.co/image/xxxx", width: 640 },
        { height: 320, url: "https://i.scdn.co/image/xxxx", width: 320 },
        { height: 160, url: "https://i.scdn.co/image/xxxx", width: 160 },
      ],
      name: "Arctic Monkeys",
      popularity: 10,
      top_tracks: {},
      external_urls: { spotify: "https://open.spotify.com/artist/xxxx" },
      href: "https://api.spotify.com/v1/artists/xxxx",
      id: id,
      type: "artist",
      uri: "spotify:artist:xxxx"
    }.with_indifferent_access
  end
end
