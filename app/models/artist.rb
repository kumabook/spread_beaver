# frozen_string_literal: true

require "pink_spider"
class Artist < ApplicationRecord
  include Enclosure
  has_many :enclosure_artists
  has_many :tracks, through: :enclosure_artists, source: :enclosure, source_type: Track.name
  has_many :albums, through: :enclosure_artists, source: :enclosure, source_type: Album.name
  belongs_to :identity, class_name: "ArtistIdentity", optional: true

  def find_or_create_by_content(content)
    model = find_or_create_by(id: content["id"]) do |m|
      m.update_by_content(content)
    end
    model
  end

  def update_by_content(content)
    self.provider      = content["provider"]
    self.identifier    = content["identifier"]
    self.url           = content["url"]
    self.name          = content["name"]
    self.thumbnail_url = content["thumbnail_url"]
    self.artwork_url   = content["artwork_url"]
    self.created_at    = content["created_at"]
    self.updated_at    = content["updated_at"]
  end

  def self.find_or_create_by_apple_music_artist(artist)
    find_or_create_by(provider: "AppleMusic", identifier: artist.id) do |m|
      m.url           = artist.url
      m.name          = artist.name
      m.thumbnail_url = artist.thumbnail_url
      m.artwork_url   = artist.artwork_url
      m
    end
  end

  def self.find_or_create_by_spotify_artist(artist)
    find_or_create_by(provider: "Spotify", identifier: artist.id) do |m|
      m.url           = artist.uri
      m.name          = artist.name
      m.thumbnail_url = artist.images.first&.dig("url")
      m.artwork_url   = artist.images.first&.dig("url")
      m
    end
  end

  def permalink_url
    case provider
    when "Spotify"
      s = url.split(":")
      "http://open.spotify.com/artist/#{s[2]}"
    else
      url
    end
  end

  def title
    name
  end

end
