# frozen_string_literal: true

class LikedEnclosure < ApplicationRecord
  include EnclosureMark
  include_stream_scopes

  belongs_to :user
  belongs_to :enclosure, counter_cache: :likes_count, touch: true, polymorphic: true

  belongs_to :track   , foreign_key: "enclosure_id", required: false
  belongs_to :album   , foreign_key: "enclosure_id", required: false
  belongs_to :playlist, foreign_key: "enclosure_id", required: false
end
