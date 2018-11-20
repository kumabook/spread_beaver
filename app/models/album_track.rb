# frozen_string_literal: true

class AlbumTrack < ApplicationRecord
  include EnclosureMark
  belongs_to :track
  belongs_to :album
  validates :track_id, uniqueness: {scope: :album_id}
end
