# frozen_string_literal: true

class AlbumIdentity < ApplicationRecord
  include Enclosure
  include Identity
  has_many :items, class_name: "Album", foreign_key: :identity_id
  has_many :album_track_identities
  has_many :album_artist_identities
  has_many :track_identities , through: :album_track_identities
  has_many :artist_identities, through: :album_artist_identities
  has_many :keywordables     , dependent: :destroy, as: :keywordable
  has_many :keywords         , through: :keywordables

  def self.find_or_create_by_album(album)
    case album.provider
    when "Spotify"
      a = RSpotify::Album.find(album.identifier)
      find_or_create_by_spotify_album(t)
    when "AppleMusic"
      s = AppleMusic::Album.find("jp", album.identifier)
      find_or_create_by_apple_music_album(s)
    end
  end

  def self.find_or_create_by_spotify_album(a)
    find_or_create_by(name: a.name, artist_name: a.artists.map(&:name).join(", "))
  end

  def self.find_or_create_by_apple_music_album(album)
    find_or_create_by(name: album.name, artist_name: album.artist_name)
  end

  def self.build_by_spotify_album(album)
    return nil if album.nil?
    item = Album.find_or_create_by_spotify_album(album)
    return item.identity if item.identity.present?
    artist_names = album.artists.map(&:name).join(", ")
    identity = AlbumIdentity.find_or_create_by(name: album.name, artist_name: artist_names)
    identity.update_associations_by_spotify_album(album)
    identity.search_apple_music
    identity
  end

  def self.build_by_apple_music_album(album)
    return nil if album.nil?
    item = Album.find_or_create_by_apple_music_album(album)
    return item.identity if item.identity.present?
    identity = AlbumIdentity.find_or_create_by(name: album.name, artist_name: album.artist_name)
    identity.update_associations_by_apple_music_album(album)
    identity.search_spotify
    identity
  end

  def update_associations_by_spotify_album(album)
    artist_identities = album.artists.map do |artist|
      ArtistIdentity::build_by_spotify_artist(artist)
    end

    artist_identities.each do |artist_identity|
      AlbumArtistIdentity.find_or_create_by(album_identity_id:  id,
                                            artist_identity_id: artist_identity.id)
    end
=begin
    album.genres.each do |genre|
      genre_tag = Tag.find_or_create_by(genre, "genre")
      add_tag(genre_tag)
    end
=end
    item = Album.find_or_create_by_spotify_album(album)
    item.identity = self
    item.save!
    self
  end

  def update_associations_by_apple_music_album(album)
    item = Album.find_or_create_by_apple_music_album(album)
    if album.artists.present?
      artist_ids        = album.artists.map(&:id)
      artists           = AppleMusic::Artist.find("jp", artist_ids)
      artist_identities = artists.map do |artist|
        ArtistIdentity.build_by_apple_music_artist(artist)
      end
      artist_identities.each do |identity|
        AlbumArtistIdentity.find_or_create_by(
          album_identity_id:  id,
          artist_identity_id: identity.id
        )
      end
    end
=begin
    album.genres.each do |genre|
      genre_tag = Tag::find_or_create_by(genre.name, "genre")
      add_tag(genre_tag)
    end
=end
    item.identity = self
    item.save!
    self
  end

  def search_apple_music
    albums = AppleMusic::Album.search("jp", [name, artist_name])
    albums = AppleMusic::Album.search("jp", [name]) if albums.blank?
    return if albums.blank?

    AppleMusic::Album.find("jp", albums.map(&:id)).each do |a|
      if albums.count == 1 || (a.name == name && a.artist_name == artist_name)
        album = Album.find_or_create_by_apple_music_album(a)
        album.identity = self
        album.save!
      end
    end
  end

  def search_spotify
    q = "#{name}"
    artist_identities.each do |artist|
      q += " artist:#{artist.name}"
    end
    sp_albums = RSpotify::Album.search(q, limit: 10)
    sp_albums.each do |sp_album|
      if sp_albums.count == 1 || (sp_album.name == name)
        album = Album.find_or_create_by_spotify_album(sp_album)
        album.identity = self
        album.save!
      end
    end
  end

  def search_items
    search_apple_music
    search_spotify
  end
end
