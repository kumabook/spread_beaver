# frozen_string_literal: true

class Genre < ApplicationRecord
  has_many :genre_items
  has_many :album_identities , through: :genre_items, source: :genre_items, source_type: "AlbumIdentitiy"
  has_many :artist_identities, through: :genre_items, source: :genre_items, source_type: "ArtistIdentitiy"

  def self.find_by_name(name)
    find_by(label: name) || find_by(japanese_label: name)
  end

  def self.find_or_create_by_name(name)
    find_by_name(name) || create(label: name)
  end
end
