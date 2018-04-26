# frozen_string_literal: true

class LikedEnclosure < ApplicationRecord
  include EnclosureMark
  include_stream_scopes

  belongs_to :user
  belongs_to :enclosure, counter_cache: :likes_count, touch: true
end
