class LikedEnclosure < ApplicationRecord
  include EnclosureMark
  belongs_to :user
  belongs_to :enclosure, counter_cache: :likes_count, touch: true
end
