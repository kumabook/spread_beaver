# frozen_string_literal: true

require "pink_spider"
class Track < ApplicationRecord
  include Enclosure
  has_many :enclosure_artists, dependent: :destroy, as: :enclosure
  has_many :artists, through: :enclosure_artists
  has_many :album_tracks
  has_many :albums, through: :album_tracks

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
    hash["playlists"] = nil
    hash
  end

  def as_detail_json
    hash = super
    hash["playlists"] = playlists.map(&:as_content_json) if playlists.present?
    hash
  end
end
