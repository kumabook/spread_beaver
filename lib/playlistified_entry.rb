class PlaylistifiedEntry
  attr_reader(:id,
              :url,
              :title,
              :descriptions,
              :visual_url,
              :locale,
              :tracks,
              :playlists,
              :albums,
              :entry)
  def initialize(id, url, title, description, visual_url, locale, tracks, playlists, albums, entry)
    @id          = id
    @url         = url
    @title       = title
    @description = description
    @visual_url  = visual_url
    @locale      = locale
    @tracks      = tracks
    @playlists   = playlists
    @albums      = albums
    @entry       = entry
  end

  def create_enclosures(items, type)
    models = items.map do |i|
      model = Enclosure.find_or_create_by(id: i['id'], type: type) do
        puts "New enclosure #{i['provider']} #{i['identifier']}}"
      end
      EntryEnclosure.find_or_create_by entry:          @entry,
                                       enclosure:      model,
                                       enclosure_type: type do
        puts "Add new #{type} #{i['id']} to entry #{@entry.id}"
      end
      model.content = i
      model
    end
    models
  end

  def create_tracks
    create_enclosures(@tracks, Track.name)
  end

  def create_playlists
    create_enclosures(@playlists, Playlist.name)
  end

  def create_albums
    create_enclosures(@albums, Album.name)
  end
end
