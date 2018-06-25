# frozen_string_literal: true

require "pink_spider"
class Artist < ApplicationRecord
  include EnclosureConcern
  has_many :enclosure_artists
  has_many :tracks, through: :enclosure_artists, source: :enclosure, source_type: Track.name
  has_many :albums, through: :enclosure_artists, source: :enclosure, source_type: Album.name

  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when "Spotify"
      s = @content["url"].split(":")
      "http://open.spotify.com/artist/#{s[2]}"
    else
      @content["url"]
    end
  end
end
