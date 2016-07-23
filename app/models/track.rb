class Track < ActiveRecord::Base
  has_many :entry_tracks
  has_many :entries, through: :entry_tracks
  has_many :likes
  has_many :users, through: :likes

  scope :detail,  ->        { includes(:users).includes(:entries) }
  scope :latest,  -> (time) { where("created_at > ?", time).order('created_at DESC') }
  scope :popular, ->        { joins(:users).includes(:entries).order('saved_count DESC') }
  scope :liked,   ->  (uid) { joins(:users).includes(:entries).where(users: { id: uid }) }

  def self.url provider, identifier
    case provider
    when 'YouTube'
      "https://www.youtube.com/watch?v=#{identifier}"
    when 'SoundCloud'
      "https://api.soundcloud.com/tracks/#{identifier}"
    end
  end

  def likesCount
    likes.size
  end

  def as_detail_json
    hash = as_json include: {
                     users: { except: [:crypted_password, :salt] }
                   }
    hash['url']        = Track.url provider, identifier
    hash['likesCount'] = likesCount
    hash['likers']     = hash['users']
    hash['entries']    = entries.map { |e| e.as_json }
    hash.delete('users')
    hash
  end

  def to_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
      .merge({ likesCount: likesCount})
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

  def self.popular_tracks_within_period(from: nil, to: nil)
    raise ArgumentError, "Parameter must be not nil" if from.nil? || to.nil?
    # TODO: Add page and per_page if need be
    user_count_hash = Like.period(from, to).user_count
    tracks = Track.find(user_count_hash.keys)
    # order by user_count and updated
    user_count_hash.keys.map { |id|
      {
                id: id,
        user_count: user_count_hash[id],
             track: tracks.select { |t| t.id == id }.first
      }
    }.sort_by { |hash|
      [hash[:user_count], hash[:track].updated_at]
    }.reverse.map { |hash| hash[:track] }
  end
end
