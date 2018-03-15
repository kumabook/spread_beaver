require 'rest_client'
require 'json'
require 'active_support'
require 'active_support/core_ext'

class PinkSpider
  attr_reader(:base_url)
  def initialize(url = nil)
    @base_url = url || ENV["PINK_SPIDER_URL"] || 'http://localhost:8080'
  end

  def create_feed(url)
    response = RestClient.post "#{base_url}/v1/feeds",
                               { url: url }.to_json,
                               {content_type: :json, accept: :json}
    return if response.code != 200
    JSON.parse(response.body)
  end

  def fetch_feed(id)
    response = RestClient.get "#{base_url}/v1/feeds/#{id}",
                               accept: :json
    return if response.code != 200
    JSON.parse(response.body)
  end

  def fetch_feeds(ids)
    response = RestClient.post "#{base_url}/v1/feeds/.mget",
                               ids.to_json,
                               {content_type: :json, accept: :json}
    return if response.code != 200
    JSON.parse(response.body)
  end

  def fetch_entries_of_feed(url, newer_than)
    response = RestClient.get "#{base_url}/v1/entries",
                              params: { feed_url: url, newer_than: newer_than },
                              accept: :json
    return if response.code != 200
    JSON.parse(response.body)
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

  def fetch_active_playlists()
    response = RestClient.get "#{base_url}/v1/playlists",
                              params: { type: "active" },
                              accept: :json
    return if response.code != 200
    JSON.parse(response.body)
  end

  def fetch_tracks_of_playlist(playlist_id, newer_than)
    response = RestClient.get "#{base_url}/v1/playlists/#{playlist_id}/tracks",
                              params: { newer_than: newer_than },
                              accept: :json
    return if response.code != 200
    JSON.parse(response.body)
  end

  def fetch_track(id)
    fetch_item(id, 'tracks')
  end

  def fetch_tracks(ids)
    fetch_items(ids, 'tracks')
  end

  def search_tracks(query, page, per_page)
    search_items(query, page, per_page, 'tracks')
  end

  def create_track(params)
    create_item('tracks', params)
  end

  def fetch_playlist(id)
    fetch_item(id, 'playlists')
  end

  def fetch_playlists(ids)
    fetch_items(ids, 'playlists')
  end

  def search_playlists(query, page, per_page)
    search_items(query, page, per_page, 'playlists')
  end

  def create_playlist(params)
    create_item('playlists', params)
  end

  def update_playlist(id, params)
    update_item('playlists', id, params)
  end

  def fetch_album(id)
    fetch_item(id, 'albums')
  end

  def fetch_albums(ids)
    fetch_items(ids, 'albums')
  end

  def search_albums(query, page, per_page)
    search_items(query, page, per_page, 'albums')
  end

  def create_album(params)
    create_item('albums', params)
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

  def search_items(query, page, per_page, resource_name)
    response = RestClient.get "#{base_url}/v1/#{resource_name}",
                              params: {
                                query:    query,
                                page:     page,
                                per_page: per_page,
                              },
                              accept: :json
    return if response.code != 200
    JSON.parse(response.body)
  end

  def create_item(resource_name, params)
    response = RestClient.post "#{base_url}/v1/#{resource_name}",
                               params,
                               accept: :json
    return if response.code != 200
    JSON.parse(response.body)
  end

  def update_item(resource_name, id, params)
    response = RestClient.post("#{base_url}/v1/#{resource_name}/#{id}",
                               params,
                               accept: :json)
    return if response.code != 200
    JSON.parse(response)
  end

end
