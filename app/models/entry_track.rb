class EntryTrack < ApplicationRecord
  belongs_to :entry
  belongs_to :track, counter_cache: :entries_count, touch: true
end
