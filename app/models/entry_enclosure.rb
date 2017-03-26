class EntryEnclosure < ApplicationRecord
  belongs_to :entry
  belongs_to :enclosure, polymorphic: true, counter_cache: :entries_count, touch: true

  scope :period,     -> (from, to) { where("created_at >= ?", from).where("created_at <= ?", to) }
  scope :entry_count, ->            { group(:enclosure_id).order('count_entry_id DESC').count('entry_id') }
end
