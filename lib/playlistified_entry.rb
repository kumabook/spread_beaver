class PlaylistifiedEntry
  attr_reader(:id,
              :url,
              :title,
              :descriptions,
              :visual_url,
              :locale,
              :tracks,
              :entry)
  def initialize(id, url, title, description, visual_url, locale, tracks, entry)
    @id          = id
    @url         = url
    @title       = title
    @description = description
    @visual_url  = visual_url
    @locale      = locale
    @tracks      = tracks
    @entry       = entry
  end

  def create_tracks
    tracks = @tracks.map do |t|
      track = Track.find_or_create_by(id: t['id'],
                                      provider: t['provider'],
                                      identifier: t['identifier']) do
        puts "New track #{t['provider']} #{t['identifier']}}"
      end
      track.url = Track::url t['provider'], t['identifier']
      EntryEnclosure.find_or_create_by entry:          @entry,
                                       enclosure:      track,
                                       enclosure_type: Track.name do
        puts "Add new track #{t['provider']} #{t['identifier']} " +
             "to entry #{@entry.id}"
      end
      track
    end
    tracks
  end
end
