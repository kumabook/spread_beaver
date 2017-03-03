class EntryEnclosure < ApplicationRecord
  belongs_to :entry
  belongs_to :enclosure, polymorphic: true, counter_cache: :entries_count, touch: true
end
