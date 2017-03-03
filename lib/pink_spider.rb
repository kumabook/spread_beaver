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

  def fetch_track(track_id)
    response = RestClient.get "#{base_url}/v1/tracks/#{track_id}",
                              accept: :json
    return if response.code != 200
    JSON.parse(response)
  end

  def fetch_tracks(track_ids)
    return [] if track_ids.blank?
    response = RestClient.post "#{base_url}/v1/tracks/.mget",
                               track_ids.to_json,
                               {content_type: :json, accept: :json}
    return if response.code != 200
    JSON.parse(response)
  end
end
