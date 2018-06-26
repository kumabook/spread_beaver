# frozen_string_literal: true

require "pink_spider"
class Album < ApplicationRecord
  include EnclosureConcern
  has_many :enclosure_artists, dependent: :destroy, as: :enclosure
  has_many :artists, through: :enclosure_artists

  def title
    fetch_content if @content.nil?
    "#{@content['title']} / #{@content['owner_name']}"
  end

  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when "Spotify"
      s = @content["url"].split(":")
      "http://open.spotify.com/album/#{s[2]}"
    else
      @content["url"]
    end
  end
end
