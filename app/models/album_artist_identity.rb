# frozen_string_literal: true

class AlbumArtistIdentity < ApplicationRecord
  belongs_to :album_identity
  belongs_to :artist_identity
end
