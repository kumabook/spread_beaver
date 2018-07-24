# frozen_string_literal: true

class SavedEnclosure < ApplicationRecord
  include EnclosureMark
  include_stream_scopes

  belongs_to :user
  belongs_to :enclosure, counter_cache: :saved_count, touch: true, polymorphic: true

  belongs_to :track   , foreign_key: "enclosure_id", required: false
  belongs_to :album   , foreign_key: "enclosure_id", required: false
  belongs_to :artist  , foreign_key: "enclosure_id", required: false
  belongs_to :playlist, foreign_key: "enclosure_id", required: false

  belongs_to :track_identity , foreign_key: "enclosure_id", required: false
  belongs_to :album_identity , foreign_key: "enclosure_id", required: false
  belongs_to :artist_identity, foreign_key: "enclosure_id", required: false
end
