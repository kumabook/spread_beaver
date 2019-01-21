# frozen_string_literal: true

class TrackIdentity < ApplicationRecord
  include Enclosure
  include Identity
  has_many :items, class_name: "Track", foreign_key: :identity_id
  has_many :album_track_identities
  has_many :track_artist_identities
  has_many :album_identities , through: :album_track_identities
  has_many :artist_identities, through: :track_artist_identities
  has_many :keywordables     , dependent: :destroy, as: :keywordable
  has_many :keywords         , through: :keywordables

  scope :with_detail, -> {
    eager_load(:entries, :items, :album_identities, :artist_identities)
  }

  def self.find_or_create_by_track(track)
    case track.provider
    when "Spotify"
      t = RSpotify::Track.find(track.identifier)
      find_or_create_by_spotify_track(t)
    when "AppleMusic"
      s = AppleMusic::Song.find("jp", [track.identifier])
      find_or_create_by_apple_music_song(s)
    end
  end

  def self.find_or_create_by_spotify_track(t)
    find_or_create_by(name: t.name, artist_name: t.artists.map(&:name).join(", ")) do |identity|
      identity.slug = new_slug(t.name)
    end
  end

  def self.find_or_create_by_apple_music_song(s)
    find_or_create_by(name: s.name, artist_name: s.artist_name) do |identity|
      identity.slug = new_slug(s.name)
    end
  end

  def self.build_by_spotify_track(track)
    return nil if track.nil?
    item = Track.find_or_create_by_spotify_track(track)
    return item.identity if item.identity.present?
    identity = find_or_create_by_spotify_track(track)
    identity.update_associations_by_spotify_track(track)
    identity.search_apple_music
    identity
  end

  def self.build_by_apple_music_song(song)
    return nil if song.nil?
    item = Track.find_or_create_by_apple_music_song(song)
    return item.identity if item.identity.present?
    identity = find_or_create_by_apple_music_song(song)
    identity.update_associations_by_apple_music_song(song)
    identity.search_spotify
    identity
  end

  def update_associations_by_spotify_track(track)
    sp_album = RSpotify::Album.find(track.album.id)
    album_identity = AlbumIdentity.build_by_spotify_album(sp_album)
    if album_identity.present?
      AlbumTrackIdentity.find_or_create_by(track_identity_id: id,
                                           album_identity_id: album_identity.id)
    end

    artist_identities = track.artists.map do |artist|
      ArtistIdentity.build_by_spotify_artist(artist)
    end
    artist_identities.each do |artist_identity|
      TrackArtistIdentity.find_or_create_by(track_identity_id: id,
                                            artist_identity_id: artist_identity.id)
    end

    item = Track.find_or_create_by_spotify_track(track)
    item.identity = self
    item.save!
  end

  def update_associations_by_apple_music_song(song)
    album_ids        = song.albums.map(&:id)
    albums           = AppleMusic::Album.find("jp", album_ids)
    albums.each do |album|
      album_identity = AlbumIdentity.build_by_apple_music_album(album)
      AlbumTrackIdentity.find_or_create_by(track_identity_id:  id,
                                           album_identity_id: album_identity.id)
    end
    artist_ids = song.artists.map(&:id)
    artists = AppleMusic::Artist.find("jp", artist_ids)
    artists.each do |artist|
      artist_identity = ArtistIdentity::build_by_apple_music_artist(artist)
      TrackArtistIdentity.find_or_create_by(track_identity_id:  id,
                                            artist_identity_id: artist_identity.id)
    end
    item = Track.find_or_create_by_apple_music_song(song)
    item.identity = self
    item.save!
  end

  def search_apple_music
    songs = AppleMusic::Song.search("jp", [name, artist_name])
    songs = AppleMusic::Song.search("jp", [name]) if songs.blank?
    return if songs.blank?

    AppleMusic::Song.find("jp", songs.map(&:id)).each do |song|
      if songs.count == 1 || (song.name == name && song.artist_name == artist_name)
        item = Track.find_or_create_by_apple_music_song(song)
        item.identity = self
        item.save!
      end
    end
  end

  def search_spotify
    q = "#{name}"
    artist_identities.each do |artist|
      q += " artist:#{artist.name}"
    end
    tracks = RSpotify::Track.search(q, limit: 10, market: "jp")

    tracks.each do |track|
      if tracks.count == 1 || (track.name == name)
        item = Track.find_or_create_by_spotify_track(track)
        item.identity = self
        item.save!
      end
    end
  end

  def search_items
    search_apple_music
    search_spotify
  end
end
