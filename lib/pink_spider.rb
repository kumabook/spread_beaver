require 'rest_client'
require 'json'
require 'active_support'
require 'active_support/core_ext'

class PinkSpider
  attr_reader(:base_url)
  def initialize(url = nil)
    @base_url = url || ENV["PINK_SPIDER_URL"] || 'http://localhost:8080'
  end

  def playlistify(url: '', force: false)
    response = RestClient.get("#{base_url}/v1/playlistify",
                              params: {
                                url:   url,
                                force: force,
                              },
                              accept: :json)
    return if response.code != 200
    JSON.parse(response)
  end

  def fetch_track(id)
    fetch_item(id, 'tracks')
  end

  def fetch_tracks(ids)
    fetch_items(ids, 'tracks')
  end

  def fetch_playlist(id)
    fetch_item(id, 'playlists')
  end

  def fetch_playlists(ids)
    fetch_items(ids, 'playlists')
  end

  def fetch_album(id)
    fetch_item(id, 'albums')
  end

  def fetch_albums(ids)
    fetch_items(ids, 'albums')
  end

  def fetch_item(id, resource_name)
    response = RestClient.get "#{base_url}/v1/#{resource_name}/#{id}",
                              accept: :json
    return if response.code != 200
    JSON.parse(response.body)
  end

  def fetch_items(ids, resource_name)
    return [] if ids.blank?
    response = RestClient.post "#{base_url}/v1/#{resource_name}/.mget",
                               ids.to_json,
                               {content_type: :json, accept: :json}
    return if response.code != 200
    JSON.parse(response.body)
  end
end
