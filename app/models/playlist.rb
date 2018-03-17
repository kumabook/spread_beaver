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

  def permalink_url provider, identifier
    fetch_content if @content.nil?
    @content["url"]
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
end
