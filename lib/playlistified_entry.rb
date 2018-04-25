# frozen_string_literal: true
class PlaylistifiedEntry
  attr_reader(:id,
              :url,
              :title,
              :description,
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
end
