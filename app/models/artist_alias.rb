# frozen_string_literal: true

class ArtistAlias < ApplicationRecord
  belongs_to :artist_identity, touch: true
end
