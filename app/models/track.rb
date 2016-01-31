class Track < ActiveRecord::Base
  has_many :entry_tracks
  has_many :entries, through: :entry_tracks
  def self.url provider, identifier
    case provider
    when 'YouTube'
      "https://www.youtube.com/watch?v=#{identifier}"
    when 'SoundCloud'
      "https://api.soundcloud.com/tracks/#{identifier}"
    end
  end
end
