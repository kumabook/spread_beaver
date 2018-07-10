# frozen_string_literal: true

class ArtistIdentity < ApplicationRecord
  include Enclosure
  include Identity
  has_many :items, class_name: "Artist", foreign_key: :identity_id
  has_many :track_artist_identities
  has_many :album_artist_identities
  has_many :track_identities, through: :track_artist_identities
  has_many :album_identities, through: :album_artist_identities
  has_many :artist_aliases
  has_many :keywordables    , dependent: :destroy, as: :keywordable
  has_many :keywords        , through: :keywordables

  def self.find_by_name_and_origin(name, origin_name)
    artists = joins(:artist_aliases)
                .where(artist_aliases: { name: name })
                .where(name: name)
    return artists.first if artists.count == 1
    artists.each do |artist|
      return artist if artist.origin_name == origin_name
    end
    nil
  end

  def self.find_or_create_by_artist(artist)
    case artist.provider
    when "Spotify"
      a = RSpotify::Artist.find(artist.identifier)
      find_or_create_by_spotify_album(t)
    when "AppleMusic"
      s = AppleMusic::Artist.find("jp", album.identifier)
      find_or_create_by_apple_music_album(s)
    end
  end

  def self.find_or_create_by_spotify_artist(artist)
    find_by_name_and_origin(artist.name, "") ||
      find_or_create_by(name: artist.name, origin_name: "")
  end

  def self.find_or_create_by_apple_music_artist(artist)
    find_by_name_and_origin(artist.name, "") ||
      find_or_create_by(name: artist.name, origin_name: "")
  end

  def self.build_by_spotify_artist(artist)
    return nil if artist.nil?
    item = Artist.find_or_create_by_spotify_artist(artist)
    return item.identity if item.identity.present?
    identity = find_or_create_by_spotify_artist(artist)
    identity.update_associations_by_spotify_artist(artist)
    identity.search_apple_music
    identity
  end

  def self.build_by_apple_music_artist(artist)
    return nil if artist.nil?
    item = Artist.find_or_create_by_apple_music_artist(artist)
    return item.identity if item.identity.present?
    identity = find_or_create_by_apple_music_artist(artist)
    identity.update_associations_by_apple_music_artist(artist)
    identity.search_spotify
    identity
  end

  def update_associations_by_spotify_artist(artist)
    item = Artist.find_or_create_by_spotify_artist(artist)
    artist.genres.each do |genre|
      p genre
#      genre_tag = Tag::find_or_create_by(genre, "genre")
#      add_tag(genre_tag)
    end
    artist_identity = ArtistIdentity::find_by(id: item.identity_id)
    if artist_identity.present? && id != artist_identity.id
      identity.merge_to(self)
      identity.destroy
    end
    item.identity = self
    item.save!
    ArtistAlias.find_or_create_by(artist_identity_id: id, name: artist.name)
    self
  end

  def update_associations_by_apple_music_artist(artist)
    item = Artist::find_or_create_by_apple_music_artist(artist)
    artist.genre_names.each do |genre|
      p genre
#      genre_tag = Tag.find_or_create_by(genre.name, "genre")
#      add_tag(genre_tag)
    end
    item.identity = self
    item.save!
    ArtistAlias.find_or_create_by(artist_identity_id: id, name: artist.name)
    self
  end

  def merge_to(another)
    AlbumArtistIdentity.where(artist_identity_id: id).update_all(artist_identity_id: another.id)
    TrackArtistIdentity.where(artist_identity_id: id).update_all(artist_identity_id: another.id)
    Artist.where(identity_id: id).update_all(identity_id: another.id)
    ArtistAlias.where(artist_identity_id: id).update_all(artist_identity_id: another.id)
  end

  def search_apple_music
    artists = AppleMusic::Artist.search("jp", [name])
    return if artists.blank?

    AppleMusic::Artist.find("jp", artists.map(&:id)).each do |a|
      if artists.count == 1 || a.name == name
        artist = Artist.find_or_create_by_apple_music_artist(a)
        artist.identity = self
        artist.save!
      end
    end
  end

  def search_spotify
    artists = RSpotify::Artist.search("artist:#{name}", limit: 10)
    artists.each do |artist|
      if artists.count == 1 || artist.name == name
        artist = Artist.find_or_create_by_spotify_artist(artist)
        artist.identity = self
        artist.save!
      end
    end
  end

  def search_items
    search_apple_music
    search_spotify
  end
end
