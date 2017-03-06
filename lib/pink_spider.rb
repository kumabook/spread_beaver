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
    fetch_item(id, Track.name)
  end

  def fetch_tracks(ids)
    fetch_items(ids, Track.name)
  end

  def fetch_playlist(id)
    fetch_item(id, Playlist.name)
  end

  def fetch_playlists(ids)
    fetch_items(ids, Playlist.name)
  end

  def fetch_item(id, type)
    resource_name = type.pluralize.downcase
    response = RestClient.get "#{base_url}/v1/#{resource_name}/#{id}",
                              accept: :json
    return if response.code != 200
    JSON.parse(response)
  end

  def fetch_items(ids, type)
    return [] if ids.blank?
    resource_name = type.pluralize.downcase
    response = RestClient.post "#{base_url}/v1/#{resource_name}/.mget",
                               ids.to_json,
                               {content_type: :json, accept: :json}
    return if response.code != 200
    JSON.parse(response)
  end
end
