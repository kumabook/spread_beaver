# frozen_string_literal: true

require "pink_spider"
class Playlist < ApplicationRecord
  include EnclosureConcern

  def self.find_or_create_by_content(content)
    model = find_or_create_by(id: content["id"]) do |m|
      m.update_by_content(content)
    end
    model.content = content
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
    self.velocity      = content["velocity"]
    self.thumbnail_url = content["thumbnail_url"]
    self.artwork_url   = content["artwork_url"]
    self.published_at  = content["published_at"]
    self.state         = content["state"]

    self.created_at    = content["created_at"]
    self.updated_at    = content["updated_at"]
  end

  def title
    fetch_content if @content.nil?
    "#{@content['title']} / #{@content['owner_name']}"
  end

  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when "Spotify"
      s = @content["url"].split(":")
      "http://open.spotify.com/user/#{s[2]}/playlist/#{s[4]}"
    else
      @content["url"]
    end
  end

  def tracks
    pick_enclosures.limit(PICKS_LIMIT)
  end

  def as_content_json
    hash = super
    hash["tracks"] = nil
    hash
  end

  def as_detail_json
    hash = super
    if tracks.present?
      hash["tracks"] = tracks.map do |track|
        playlist_track = @content["tracks"].find { |h| h["track_id"] == track.id }
        next playlist_track if playlist_track.nil?
        track.content = playlist_track["track"]
        playlist_track["track"] = track.as_content_json
        playlist_track
      end
      hash["tracks"].compact!
    end
    hash
  end

  def active?
    @content["velocity"] > 0
  end

  def fetch_tracks
    playlist_tracks = PinkSpider.new.fetch_tracks_of_playlist(id, updated_at)

    playlist_tracks["items"].map do |playlist_track|
      track_content = playlist_track["track"]
      Track.find_or_create_by_content(track_content)
      pt = Pick.find_or_create_by(enclosure_id:   playlist_track["track_id"],
                                  enclosure_type: Track.name,
                                  container_id:   playlist_track["playlist_id"],
                                  container_type: Playlist.name)
      pt.created_at = playlist_track["created_at"]
      pt.updated_at = playlist_track["updated_at"]
      pt.save
      pt
    end
  end

  def self.fetch_actives(page: 1, per_page: 1000)
    r = PinkSpider.new.fetch_active_playlists(page < 1 ? 0 : page - 1, per_page)
    items = r["items"].map do |item|
      Playlist.find_or_create_by_content(item)
    end
    PaginatedArray.new(items, r["total"], r["page"] + 1, r["per_page"])
  end
end
