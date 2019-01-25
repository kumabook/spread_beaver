# frozen_string_literal: true

require "pink_spider"
class Album < ApplicationRecord
  include Enclosure

  ARTIST_ORDER = "enclosure_artists.created_at DESC"

  has_many :enclosure_artists, dependent: :destroy, as: :enclosure
  has_many :album_tracks
  has_many :artists, -> { order(ARTIST_ORDER) }, through: :enclosure_artists
  has_many :tracks, -> { order("album_tracks.id") }, through: :album_tracks
  belongs_to :identity, class_name: "AlbumIdentity", optional: true

  scope :with_content, -> {
    eager_load(:entries, artists: :identity).order(ARTIST_ORDER)
  }

  scope :with_detail, -> {
    eager_load(:entries, :pick_containers, :pick_enclosures)
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
    self.published_at  = content["published_at"]
    self.state         = content["state"]

    self.created_at    = content["created_at"]
    self.updated_at    = content["updated_at"]
  end

  def self.find_or_create_by_apple_music_album(album)
    find_or_create_by(provider: "AppleMusic", identifier: album.id) do |m|
      m.owner_id      = album.artists.first&.id
      m.owner_name    = album.artist_name
      m.url           = album.url
      m.title         = album.name
      m.description   = album.editorial_notes&.dig("short")
      m.thumbnail_url = album.thumbnail_url
      m.artwork_url   = album.artwork_url
      m.published_at  = parse_release_date(album.release_date)
      m.state         = "alive"
      m
    end
  end

  def self.find_or_create_by_spotify_album(album)
    find_or_create_by(provider: "Spotify", identifier: album.id) do |m|
      m.owner_id      = album.artists.first&.id
      m.owner_name    = album.artists.first&.name
      m.url           = album.uri
      m.title         = album.name
      m.description   = nil
      m.thumbnail_url = album.images.first&.dig("url")
      m.artwork_url   = album.images.first&.dig("url")
      m.published_at  = parse_release_date(album.release_date)
      m.state         = "alive"
      m
    end
  end

  def self.parse_release_date(release_date)
    if release_date.length == 4
      Date.parse("#{release_date}/01/01")
    elsif /\d{4}-\d{2}/.match?(release_date)
      Date.parse("#{release_date}-01")
    else
      Date.parse(release_date)
    end
  end

  def permalink_url
    case provider
    when "Spotify"
      s = url.split(":")
      "http://open.spotify.com/album/#{s[2]}"
    else
      url
    end
  end

  def as_content_json
    hash = as_basic_content_json
    hash["tracks"] = nil
    hash
  end

  def as_detail_json
    hash = as_content_json
    hash["entries"] = entries.map(&:as_partial_json) if hash["entries"].nil?
    hash["tracks"] = tracks.map(&:as_content_json) if tracks.present?
    hash
  end

  def fetch_tracks
    content = PinkSpider.new.fetch_album(id)
    content["tracks"].map do |track_content|
      track = Track.find_or_create_by_content(track_content)
      AlbumTrack.find_or_create_by(album_id: content["id"],
                                   track_id: track_content["id"])
      track
    end
  end

  def create_identity
    case provider
    when "Spotify"
      AlbumIdentity.build_by_spotify_album(RSpotify::Album.find(identifier))
    when "AppleMusic"
      AlbumIdentity.build_by_apple_music_album(AppleMusic::Album.find("jp", identifier))
    end
  end
end
