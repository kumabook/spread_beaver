class Track < ActiveRecord::Base
  has_many :entry_tracks, dependent: :destroy
  has_many :entries     , through: :entry_tracks
  has_many :likes       , dependent: :destroy
  has_many :users       , through: :likes

  scope :detail,  ->        { eager_load(:users).eager_load(:entries) }
  scope :latest,  -> (time) { where("created_at > ?", time).order('created_at DESC') }
  scope :popular, ->        { eager_load(:users).eager_load(:entries).order('saved_count DESC') }
  scope :liked,   ->  (uid) { eager_load(:users).eager_load(:entries).where(users: { id: uid }) }

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
    hash['url']        = Track.url provider, identifier
    hash['likesCount'] = like_count
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
      .merge({ likesCount: like_count})
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

  def self.popular_tracks_within_period(from: nil, to: nil, page: 1, per_page: nil)
    raise ArgumentError, "Parameter must be not nil" if from.nil? || to.nil?
    user_count_hash = Like.period(from, to).user_count
    total_count     = user_count_hash.keys.count
    start_index     = [0, page - 1].max * per_page
    end_index       = [total_count - 1, start_index + per_page - 1].min
    sorted_hashes   = user_count_hash.keys.map {|id|
      {
                id: id,
        user_count: user_count_hash[id]
      }
    }.sort_by { |hash|
      hash[:user_count]
    }.reverse.slice(start_index..end_index)

    tracks = Track.eager_load(:entries)
                  .find(sorted_hashes.map {|h| h[:id] })
    sorted_tracks = sorted_hashes.map {|h|
      tracks.select { |t| t.id == h[:id] }.first
    }
    PaginatedTracks.new(sorted_tracks, total_count)
  end
end

class PaginatedTracks < Array
  attr_reader(:total_count)
  def initialize(values, total_count)
    super(values)
    @total_count = total_count
  end
end
