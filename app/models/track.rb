class Track < ApplicationRecord
  include Likable
  has_many :entry_tracks, dependent: :destroy
  has_many :entries     , through: :entry_tracks

  scope :detail,  ->        { eager_load(:users).eager_load(:entries) }
  scope :latest,  -> (time) { where("created_at > ?", time).order('created_at DESC') }

  def self.url provider, identifier
    case provider
    when 'YouTube'
      "https://www.youtube.com/watch?v=#{identifier}"
    when 'SoundCloud'
      "https://api.soundcloud.com/tracks/#{identifier}"
    end
  end

  def self.permalink_url provider, identifier
    case provider
    when 'YouTube'
      self.url(provider, identifier)
    when 'SoundCloud'
      api_url   = "http://api.soundcloud.com/tracks/#{identifier}"
      client_id = Setting.soundcloud_client_id
      params    = { :client_id => client_id}
      response  = RestClient.get api_url, params: params, :accept => :json
      return nil if response.code != 200
      hash      = JSON.parse(response)
      url       = hash["permalink_url"]
    end
  end

  def self.title provider, identifier
    case provider
    when 'YouTube'
      api_url   = "https://www.googleapis.com/youtube/v3/videos"
      key       = Setting.youtube_data_api_key
      params    = { :id => identifier, :key => key, :fields => "items(snippet(title))", :part => "snippet"}
      response  = RestClient.get api_url, params: params, :accept => :json
      return nil if response.code != 200
      hash      = JSON.parse(response)
      title     = hash['items'][0]["snippet"]["title"]
    when 'SoundCloud'
      api_url   = "http://api.soundcloud.com/tracks/#{identifier}"
      client_id = Setting.soundcloud_client_id
      params    = { :client_id => client_id}
      response  = RestClient.get api_url, params: params, :accept => :json
      return nil if response.code != 200
      hash      = JSON.parse(response)
      title     = hash["title"]
      user      = hash["user"]["username"]
      "#{title} / #{user}"
    end
  end

  def as_content_json
    hash = as_json
    hash['url']          = Track.url provider, identifier
    hash['likesCount']   = like_count
    hash['entriesCount'] = entries_count
    hash.delete('users')
    hash
  end

  def as_detail_json
    hash = as_content_json
    hash['likers']     = [] # hash['users'] TODO
    hash['entries']    = entries.map { |e| e.as_json }
    hash
  end

  def to_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
      .merge({
               likesCount:   like_count,
               entriesCount: entries_count,
             })
  end

  def to_query
    query = {
              id: id,
        provider: provider,
      identifier: identifier,
           title: title,
    }.to_query
  end

  def as_enclosure
    {
      href: "track/#{id}?#{to_query}",
      type: "application/json",
    }
  end
end
