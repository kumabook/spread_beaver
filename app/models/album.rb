# frozen_string_literal: true

require "pink_spider"
class Album < ApplicationRecord
  include Enclosure
  has_many :enclosure_artists, dependent: :destroy, as: :enclosure
  has_many :album_tracks
  has_many :artists, through: :enclosure_artists
  has_many :tracks, -> { order("album_tracks.id") }, through: :album_tracks

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
    hash = super
    hash["tracks"] = nil
    hash
  end

  def as_detail_json
    hash = super
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

end
