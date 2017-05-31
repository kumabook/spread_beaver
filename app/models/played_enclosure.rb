class PlayedEnclosure < ApplicationRecord
  include EnclosureMark
  belongs_to :user
  belongs_to :enclosure, counter_cache: :play_count, touch: true
end
