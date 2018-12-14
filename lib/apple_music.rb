# frozen_string_literal: true

require "apple_music/api_client"
require "apple_music/artist"
require "apple_music/song"
require "apple_music/music_video"
require "apple_music/album"

module AppleMusic
  class RequestError < StandardError
    attr_reader :code
    def initialize(code)
      @code = code
    end
  end

  class << self
    def configure
      yield(client)
    end

    def client
      @client ||= ApiClient.new
    end

    def resource_class(type)
      case type
      when "songs"
        Song
      when "music-videos"
        MusicVideo
      when "albums"
        Album
      when "artists"
        Artist
      when "genres"
        Genre
      else
        raise "Unknown type #{type}"
      end
    end

    def build_model_instance(h)
      clazz = AppleMusic.resource_class(h["type"])
      clazz.new(h["id"],
                h["type"],
                h["href"],
                h["attributes"] || {},
                h["relationships"] || {})
    end
  end
end
