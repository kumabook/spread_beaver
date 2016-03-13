class Playlist
  attr_reader( :id, :url, :tracks, :entry)
  def initialize(id, url, tracks, entry)
    @id     = id
    @url    = url
    @tracks = tracks
    @entry  = entry
  end

  def create_tracks
    tracks = @tracks.map do |t|
      track = Track.find_or_create_by(provider: t['provider'],
                                      identifier: t['identifier'])
      track.url = Track::url t['provider'], t['identifier']
      track.entries.push @entry if track.entries.include? @entry
      EntryTrack.create entry: @entry, track: track
      track
    end
    tracks
  end
end
