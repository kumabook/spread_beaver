# frozen_string_literal: true
require "pink_spider"
class Playlist < Enclosure
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
    pick_enclosures.select { |enc| enc.type == Track.name }
  end

  def as_detail_json
    hash = super
    hash['tracks'] = []
    if tracks.present?
      hash["tracks"] = hash["tracks"].map do |playlist_track|
        track = tracks.find { |t| t.id == playlist_track["track_id"] }
        if track.nil?
          next nil
        end
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
