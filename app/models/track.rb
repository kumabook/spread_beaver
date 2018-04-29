# frozen_string_literal: true
require "pink_spider"
class Track < Enclosure
  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when "Spotify"
      s = @content["url"].split(":")
      "http://open.spotify.com/#{s[1]}/#{s[2]}"
    else
      @content["url"]
    end
  end

  def playlists(per_page: 9)
    items = pick_containers.select { |enc| enc.type == Playlist.name }
    items.take(per_page) if per_page.present?
  end

  def as_detail_json
    hash = super
    hash["playlists"] = []
    if playlists.present?
      hash["playlists"] = playlists.map do |pl|
        pl.content = hash["playlists"].find { |h| h["id"] == pl.id }
        pl.as_content_json
      end
    end
    hash
  end
end
