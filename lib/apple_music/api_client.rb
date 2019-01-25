# frozen_string_literal: true

require "rest_client"
require "json"

BASE_URL = "https://api.music.apple.com/v1"

module AppleMusic
  class ApiClient
    attr_accessor :developer_token
    def initialize(developer_token = nil)
      @developer_token = developer_token
    end

    def get_request(path, params)
      response = RestClient.get("#{BASE_URL}#{path}",
                                {
                                  params: params,
                                  Authorization: "Bearer #{@developer_token}"
                                })
      raise AppleMusicError, response.code if response.code != 200
      JSON.parse(response.body)
    end

    def fetch_resources(country, ids, resource_name, include)
      get_request("/catalog/#{country}/#{resource_name}", {
                    ids:     ids.join(","),
                    include: include,
                  })
    end

    def fetch_songs(country, ids)
      result = fetch_resources(country, ids, "songs", "artists,albums")
      result["data"].map do |h|
        Song.new(h["id"], h["type"], h["href"], h["attributes"], h["relationships"])
      end
    end

    def fetch_song(country, id)
      fetch_songs(country, [id]).first
    end

    def fetch_music_videos(country, ids)
      result = fetch_resources(country, ids, "music_videos", "artists")
      result["data"].map do |h|
        MusicVideo.new(h["id"], h["type"], h["href"], h["attributes"], h["relationships"])
      end
    end

    def fetch_music_video(country, id)
      fetch_music_videos(country, [id]).first
    end

    def fetch_albums(country, ids)
      result = fetch_resources(country, ids, "albums", "artists")
      result["data"].map do |h|
        Album.new(h["id"], h["type"], h["href"], h["attributes"], h["relationships"])
      end
    end

    def fetch_album(country, id)
      fetch_albums(country, [id]).first
    end

    def fetch_artists(country, ids)
      result = fetch_resources(country, ids, "artists", "albums")
      result["data"].map do |h|
        Artist.new(h["id"], h["type"], h["href"], h["attributes"], h["relationships"])
      end
    end

    def fetch_artist(country, id)
      fetch_artists(country, [id]).first
    end

    def search(country, terms, limit, offset, types)
      result = get_request("/catalog/#{country}/search", {
                             term:   terms.join("+"),
                             limit:  limit,
                             offset: offset,
                             types:  types.join(",")
                           })
      %w[albums
         songs
         music_videos
         playlists
         artists].each_with_object({}) do |type, r|
        hash = result["results"][type]
        next if hash.nil?
        items = hash["data"].map do |h|
          AppleMusic.build_model_instance(h)
        end
        r[type] = {
          "href" => hash["href"],
          "data" => items,
          "next" => hash["next"],
        }
      end
    end
  end
end
