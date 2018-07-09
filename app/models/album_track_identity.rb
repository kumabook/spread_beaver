# frozen_string_literal: true

class AlbumTrackIdentity < ApplicationRecord
  belongs_to :track_identity
  belongs_to :album_identity
end
