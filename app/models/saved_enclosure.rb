class SavedEnclosure < ApplicationRecord
  include EnclosureMark
  belongs_to :user
  belongs_to :enclosure, counter_cache: :saved_count, touch: true
end
