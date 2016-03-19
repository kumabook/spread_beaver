class Track < ActiveRecord::Base
  has_many :entry_tracks
  has_many :entries, through: :entry_tracks
  has_many :likes
  has_many :users, through: :likes
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
                       users: { except: [:crypted_password, :salt] },
                     entries: {},
                   }
    hash['likesCount'] = likesCount
    hash['likers']     = hash['users']
    hash.delete('users')
    hash
  end

  def to_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
      .merge({ likesCount: likesCount})
  end
end
