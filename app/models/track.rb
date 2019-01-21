# frozen_string_literal: true

require "pink_spider"
class Track < ApplicationRecord
  include Enclosure
  has_many :enclosure_artists, dependent: :destroy, as: :enclosure
  has_many :artists, through: :enclosure_artists
  has_many :album_tracks
  has_many :albums, through: :album_tracks
  belongs_to :identity, class_name: "TrackIdentity", optional: true

  scope :with_content, -> {
    eager_load(:entries,
               :enclosure_artists,
               artists: :identity,
              )
  }

  scope :with_detail, -> {
    eager_load(:entries)
      .eager_load(:pick_containers)
      .eager_load(:pick_enclosures)
  }

  def self.find_or_create_by_content(content)
    model = find_or_create_by(id: content["id"]) do |m|
      m.update_by_content(content)
    end
    model
  end

  def update_by_content(content)
    self.provider      = content["provider"]
    self.identifier    = content["identifier"]
    self.owner_id      = content["owner_id"]
    self.owner_name    = content["owner_name"]
    self.url           = content["url"]
    self.title         = content["title"]
    self.description   = content["description"]
    self.thumbnail_url = content["thumbnail_url"]
    self.artwork_url   = content["artwork_url"]
    self.audio_url     = content["audio_url"]
    self.duration      = content["duration"]
    self.published_at  = content["published_at"]
    self.state         = content["state"]

    self.created_at    = content["created_at"]
    self.updated_at    = content["updated_at"]
  end

  def self.find_or_create_by_apple_music_song(song)
    find_or_create_by(provider: "AppleMusic", identifier: song.id) do |m|
      m.owner_id      = song.artists.first.id
      m.owner_name    = song.artist_name
      m.url           = song.url
      m.title         = song.name
      m.description   = nil
      m.thumbnail_url = song.thumbnail_url
      m.artwork_url   = song.artwork_url
      m.audio_url     = song.previews.first&.dig("url")
      m.duration      = song.duration_in_millis / 1000
      m.published_at  = Date.parse(song.release_date)
      m.state         = "alive"
      m
    end
  end

  def self.find_or_create_by_spotify_track(track)
    find_or_create_by(provider: "Spotify", identifier: track.id) do |m|
      m.owner_id      = track.artists.first.id
      m.owner_name    = track.artists.first.name
      m.url           = track.uri
      m.title         = track.name
      m.description   = nil
      m.thumbnail_url = track.album&.images&.first&.dig("url")
      m.artwork_url   = track.album&.images&.first&.dig("url")
      m.audio_url     = track.preview_url
      m.duration      = track.duration_ms / 1000
      m.published_at  = Time.zone.now
      m.state         = "alive"
      m
    end
  end

  def create_identity
    case provider
    when "Spotify"
      TrackIdentity.build_by_spotify_track(RSpotify::Track.find(identifier))
    when "AppleMusic"
      TrackIdentity.build_by_apple_music_song(AppleMusic::Song.find("jp", identifier))
    end
  end

  def permalink_url
    case provider
    when "Spotify"
      s = url.split(":")
      "http://open.spotify.com/#{s[1]}/#{s[2]}"
    else
      url
    end
  end

  def playlists
    pick_containers
  end

  def as_content_json
    hash = super
    hash["identity"] = identity.as_json
    hash["playlists"] = nil
    hash["artists"] = artists.map(&:as_content_json)
    hash
  end

  def as_detail_json
    hash = super
    hash["playlists"] = playlists.map(&:as_content_json) if playlists.present?
    hash
  end
end
