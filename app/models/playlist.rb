require 'pink_spider'
class Playlist < Enclosure
  def get_content
    PinkSpider.new.fetch_playlist(id)
  end

  def fetch_content
    @content = get_content
  end

  def title
    fetch_content if @content.nil?
    "#{@content["title"]} / #{@content["owner_name"]}"
  end

  def permalink_url
    fetch_content if @content.nil?
    case @content["provider"]
    when 'Spotify'
      s = @content["url"].split(':')
      "http://open.spotify.com/user/#{s[2]}/playlist/#{s[4]}"
    else
      @content["url"]
    end
  end

  def is_active
    @content['velocity'] > 0
  end

  def activate
    self.class.update_content(id, { velocity: 10.0 })
  end

  def deactivate
    self.class.update_content(id, { velocity: 0.0 })
  end

  def fetch_tracks
    playlist_tracks = PinkSpider.new.fetch_tracks_of_playlist(id, updated_at)

    playlist_tracks["items"].map do |playlist_track|
      track_content = playlist_track["track"]
      Track.find_or_create_by_content(track_content)
      pt = Pick.find_or_create_by(enclosure_id:   playlist_track["track_id"],
                                  enclosure_type: Track.name,
                                  container_id:   playlist_track["playlist_id"],
                                  container_type: Playlist.name) do |m|
        m.created_at = playlist_track["created_at"]
        m.updated_at = playlist_track["updated_at"]
      end
      pt.touch
      pt.save
      pt
    end
  end

  def self.fetch_actives
    contents  = PinkSpider.new.fetch_active_playlists()
    contents["items"].map do |c|
      Playlist.find_or_create_by_content(c)
    end
  end

  def self.crawl
    playlists = Playlist.fetch_actives()
    info = {
      total_playlists: playlists.count,
      total_tracks:    0,
    }
    playlists.each do |playlist|
      tracks = playlist.fetch_tracks()
      info = info.merge({
                          total_tracks: info[:total_tracks] + tracks.count
                        })
    end
    info
  end
end
