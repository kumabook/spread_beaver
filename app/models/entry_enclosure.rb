class EntryEnclosure < ApplicationRecord
  belongs_to :entry
  belongs_to :enclosure, polymorphic: true, counter_cache: :entries_count, touch: true

  scope :entry_count,     -> { group(:enclosure_id).order('count_entry_id DESC').count('entry_id') }
  scope :enclosure_count, -> { group(:entry_id).order('count_enclosure_id DESC').count('enclosure_id') }
  scope :feed_count, -> {
    group('enclosure_id')
      .joins(:entry)
      .order('count_entries_feed_id DESC')
      .distinct.count('entries.feed_id')
  }
  scope :period, -> (from, to) {
    where("entry_enclosures.created_at >= ?", from)
      .where("entry_enclosures.created_at <= ?", to)
  }
end
