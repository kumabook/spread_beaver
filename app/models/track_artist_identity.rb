# frozen_string_literal: true

class TrackArtistIdentity < ApplicationRecord
  belongs_to :track_identity
  belongs_to :artist_identity
end
