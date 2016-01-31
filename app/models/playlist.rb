class Playlist
  attr_reader( :id, :url, :tracks)
  def initialize(id, url, tracks)
    @id     = id
    @url    = url
    @tracks = tracks
  end
end
